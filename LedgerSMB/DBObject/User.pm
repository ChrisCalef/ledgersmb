package LedgerSMB::DBObject::User;

use base qw/LedgerSMB::DBObject/;
use Data::Dumper;
use strict;

=over

=item LedgerSMB::User->country_codes();

Returns a hash where the keys are registered locales and the values are the
textual representation of the locale name.

=cut

sub country_codes {
    use Locale::Country;
    use Locale::Language;

    my %cc = ();

    # scan the locale directory and read in the LANGUAGE files
    opendir DIR, "${LedgerSMB::Sysconfig::localepath}";

    my @dir = grep !/^\..*$/, readdir DIR;

    foreach my $dir (@dir) {
        $dir = substr( $dir, 0, -3 );
        $cc{$dir} = code2language( substr( $dir, 0, 2 ) );
        $cc{$dir} .= ( "/" . code2country( substr( $dir, 3, 2 ) ) )
          if length($dir) > 2;
        $cc{$dir} .= ( " " . substr( $dir, 6 ) ) if length($dir) > 5;
    }

    closedir(DIR);

    %cc;

}

sub save_preferences {
    my ($self) = @_;
    $self->exec_method(funcname => 'user__save_preferences');
    $self->{dbh}->commit;
    $self->get_user_info;
}

sub change_my_password {
    my ($self) = @_;
    if ($self->{new_password} ne $self->{confirm_password}){
        $self->error($self->{_locale}->text('Passwords must match.'));
        die;
    }
    $self->{password} = $self->{new_password};
    $self->exec_method(funcname => 'user__change_password');
    $self->{dbh}->commit;
}


sub get_option_data {
    my $self = shift @_;
    $self->{dateformats} = [];
    $self->{numberformats} = [];
    for my $opt (qw(mm-dd-yy mm/dd/yy dd-mm-yy dd/mm/yy dd.mm.yy yyyy-mm-dd)){
        push @{$self->{dateformats}}, {format => $opt};
    }
    for my $opt (qw(1,000.00 1000.00 1.000,00 1000,00 1'000.00)){
        push @{$self->{numberformats}}, {format => $opt};
    }

    my %country_codes = country_codes();
    $self->{country_codes};

    foreach my $key ( sort { $country_codes{$a} cmp $country_codes{$b} }
        keys %country_codes )
    {
        push @{$self->{country_codes}}, {
            label => $country_codes{$key},
            id => $key,
        };
    }

    $self->{cssfiles} = [];
    opendir CSS, "css/.";
    for my $opt (grep /.*\.css$/, readdir CSS){
         push @{$self->{cssfiles}}, {file => $opt};
    }
    closedir CSS;

    $self->{printers} = [];    

    if ( %{LedgerSMB::Sysconfig::printer} && ${LedgerSMB::Sysconfig::latex} ) {
        foreach my $item ( sort keys %{LedgerSMB::Sysconfig::printer} ) {
            push @{$self->{printers}}, {printer => $item};
        }
    }
    my ($pw_expiration) = $self->exec_method(
            funcname => 'user__check_my_expiration');
    $self->{password_expires} = $pw_expiration->{user__check_my_expiration};
}

sub save {
    
    my $self = shift @_;
    
    my $user = $self->get();
    
    if ( $user->{id} && $self->{is_a_user} ) {
    
        # doesn't check for the password - that's done in the sproc.
        $self->{id} = shift @{ $self->exec_method(funcname=>'admin__save_user', 
            args=>[$user->{id}, $self->{username}, $self->{password}] ) }; 
        if (!$self->{id}) {
            
            return 0;
        }
    }
    elsif ($user && !$self->{is_a_user}) {
        
        # there WAS a user, and we've decided we want that user to go away now.
        
        $self->{id} = $user->{id};
        return $self->remove();
        
    }
    elsif ($self->{is_a_user}) {
        
        # No user ID, meaning, creating a new one.        
        $self->{id} = shift @{ $self->exec_method(funcname=>'admin__save_user', 
            args=>[undef, $self->{username}, $self->{password}] ) };
    }
    return 1;
}

sub get {
    
    my $self = shift @_;
    my $id = shift;
    if ($id){
        $self->{user_id} = $id;
    }
    my ($user) = $self->exec_method(
        funcname=>'admin__get_user',
        );
    print STDERR "Point 1\n";
    $self->{user} = $user;
    my ($prefs) = $self->exec_method(
        funcname=>'user__get_preferences',
        );
    print STDERR "Point 1\n";
    $self->{prefs} = $prefs;
    print STDERR "Point 2\n";
#    $self->{person} = @{ $self->exec_method(
#        funcname=>'admin__user_preferences',
#        args=>[$self->{user}->{entity_id}]
#        )
#    }[0];
    my ($emp) = $self->exec_method(
        funcname=>'employee__get',
        args=>[$self->{user}->{entity_id}]
        );
    $self->{employee} = $emp;
    my ($ent) = $self->exec_method( 
        funcname=>'entity__get_entity',
        args=>[ $self->{user}->{entity_id} ] 
        );
    $self->{entity} = $ent;
    my @roles = $self->exec_method(
        funcname=>'admin__get_roles_for_user',
    );
    # Now, location and stuff.
    my @loc = $self->exec_method(
        funcname=>'person__list_locations',
        args=>[ $self->{user}->{entity_id} ]
    );
    $self->{locations} = \@loc;
    my @contacts = $self->exec_method(
        funcname=>"person__list_contacts",
        args=>[$self->{user}->{entity_id} ]
    );
    $self->{contacts} = \@contacts;
    my @rolstore;

    for my $role (@roles) {
        my $rolname = $role->{'admin__get_roles_for_user'};
        my $company = $self->{company};
        $rolname =~ s/lsmb_${company}__//gi;
        push @rolstore, $rolname; # Only one key=>value pair
    }
    $self->{roles} = \@rolstore;
    
    $self->{entity_id} = $self->{entity}->{id};
    print STDERR "Got all user information";
    
    #$user->{user} = $u->get($id);
    #$user->{pref} = $u->preferences($id);
    #$user->{employee} = $u->employee($user->{user}->{entity_id});
    #$user->{person} = $u->person($user->{user}->{entity_id});
    #$user->{entity} = $u->entity($id);
    #$user->{roles} = $u->roles($id);
}

sub remove {
    
    my $self = shift;
    
    my $code = $self->exec_method(funcname=>"admin__delete_user", args=>[$self->{id}, $self->{username}]);
    $self->{id} = undef; # never existed..
    
    return $code->[0];
}

sub save_prefs {
    
    my $self = shift @_; 
    
    my $pref_id = $self->exec_method(funcname=>"admin__save_preferences", 
        args=>[
            'language',
            'stylesheet',
            'printer',
            'dateformat',
            'numberformat'
        ]
    );
}

sub get_all_users {
    
    my $self = shift @_;
    
    my @ret = $self->exec_method( funcname=>"user__get_all_users" );
    $self->{users} = \@ret;
}

sub roles {
    
    my $self = shift @_;
    my $id = shift @_;
    
    
}

sub save_contact {
    
    my $self = shift @_;
    my $id = shift @_;
    my $class = shift @_;
    my $contact = shift @_;
    my @ret;
    
    print STDERR Dumper($self->{entity}->{id});
    if ($id) {
        print STDERR "Found ID..";
        @ret = $self->exec_method(funcname=>"person__save_contact", 
            args=>[
                $self->{entity}->{id},
                $self->{contacts}->[$id]->{contact_class},
                $self->{contacts}->[$id]->{contact},
                $contact
            ]
        );
    } 
    else{
        print STDERR "Did not find an ID, attempting to save a new contact..\n";
        print STDERR ($class."\n");
        print STDERR ($contact."\n");
        print STDERR ($self->{entity_id}."\n");
        @ret = $self->exec_method(funcname=>"person__save_contact",
            args=>[
                $self->{entity_id},
                $class,
                undef,
                $contact
            ]
        );
    }
    print STDERR Dumper(\@ret);
    if ($ret[0]->{person__save_contact} == 1){
        $self->{dbh}->commit();
    }
    else{
        $self->error("Couldn't save contact...");
    }
    return 1;
}

sub delete_contact {
    
    my $self = shift @_;
    my $id = shift @_;
    
    # Okay
    # ID doesn't actually conform to any database entry
    # We're basically cheating outrageously here.
    
    
}

1;
