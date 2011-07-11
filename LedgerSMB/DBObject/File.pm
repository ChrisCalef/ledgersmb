=pod

=head1 NAME

LedgerSMB::DBOBject::File

=head1 SYNPSIS

This provides routines for managing file attachments.  Subclasses may be used
to provide functionality for specific types of file attachments.

=head1 PROPERTIES/ACCESSORS

=over

=cut


package LedgerSMB::DBOBject::File;
use Class::Struct;
use LedgerSMB::DBObject;

=item  attached_by_id

Entity id of the individual who attached the file.

=item attached_by

Entity name of individual who attached file

=item attached_at 

Timestamp of attachment point.

=item content

This stores the binary content of the file.

=item mime_type_id

ID of the MIME type.  Undef if unknown.

=item mime_type_text

Standard text code of the MIME type

=item file_name

File name, user specified

=item description

Description, user specified

=item id

ID of file.  undef if unknown

=item ref_key

Referential key for the file to attach to.

=item file_class

ID of the file class.

=item src_class

ID of class of the original attachment point (for a link)

=item x-info

A hash for extended information

Note additionally the $self hashref contains the basic required attributes for
DBObject, namely dbh, _roles, and _locale. 

=back

=cut

struct LedgerSMB::DBObject::File => {
   attached_by_id =>  '$',
   attached_by    =>  '$',
   attached_at    =>  '$',
   reference      =>  '$',
   content        =>  '$',
   mime_type_id   =>  '$',
   mime_type_text =>  '$',
   file_name      =>  '$',
   description    =>  '$',
   id             =>  '$',
   ref_key        =>  '$',
   file_class     =>  '$',
   src_class      =>  '$',
   dbobject       =>  'LedgerSMB::DBObject',
   x_info         =>  '%'
};

=head1 METHODS

=over

=item new_dbobject

$file->new_dbobject({base => (LedgerSMB | LedgerSMB::Form), 
locale => LedgerSMB::Locale}); 

Creates a new file object.  Locale only needs to be specified when using
LedgerSMB::Form objects since these are not included.

Returns 0 on success.

Error codes on exit (OR'd):

1:  No database handle included
2:  No locale handle included
4:  Invalid base.


=cut

sub new_dbobject{
    use LedgerSMB;
    my ($self, $args)  = @_;
    my $dbobject;
    my $rc = 0; # Success
    if (LedgerSMB::Form->isa($args->{base})){
         use LedgerSMB::Locale;
         my $lsmb = LedgerSMB->new();
         $lsmb->merge($args->{base});
         if (LedgerSMB::Locale->isa($args->{locale})){
             $lsmb->{_locale} = $args->{locale};
             my $dbobject = LedgerSMB::DBObject({base => $lsmb});
         } else {
             $rc | 2; # No locale
         }
    }
    elsif (LedgerSMB->isa($args->{base})){
         my $dbobject = LedgerSMB::DBObject({base => $args->{base}});
    }
    else {
        $rc | 4; # Incorrect base type
    }
    if (!$dbobject->{dbh}){
        $rc | 1; # No database handle
    }
    if ($rc){
        return $rc;  # Return error.
    } else {
        $self->dbobject($dbobject);
        return 0;
    }
}

=item get

Retrives a file.  ID and file_class properties must be set.

=cut

sub get{
    my ($self) = @_;
    my ($ref) = $self->exec_method({funcname => 'file__get'});
    $self->merge($ref);
}

=item list({ref_key => int, file_class => int})

Lists files directly attached to the object.

=cut

sub list{
    my ($self, $args) = @_;
    my @results = $self->exec_method(
                 {funcname => 'file__list', 
                      args => [$args->{ref_key}, $args->{file_class}]
                 }
     );
    return @results;
}

=item list_links({ref_key => int, file_class => int})

Lists the links directly attached to the object.

=back

=cut

sub list_links{
    my ($self, $args) = @_;
    my @results = $self->exec_method(
                 {funcname => 'file__list_links', 
                      args => [$args->{ref_key}, $args->{file_class}]
                 }
     );
    return @results;
}

=item exec_method

Provides a compatible interface to LedgerSMB::DBObject::exec_method

=cut

sub exec_method{
    my ($self, $args) = @_;
    if (!scalar @{$args->{args}}){
          $self->dbobject->{attached_by_id} = $self->attached_by_id;
          $self->dbobject->{attached_by}    = $self->attached_by;
          $self->dbobject->{attached_at}    = $self->attached_at;
          $self->dbobject->{reference}      = $self->reference;
          $self->dbobject->{content}        = $self->content;
          $self->dbobject->{mime_type_id}   = $self->mime_type_id;
          $self->dbobject->{mime_type_text} = $self->mime_type_text;
          $self->dbobject->{file_name}      = $self->file_name;
          $self->dbobject->{description}    = $self->description;
          $self->dbobject->{id}             = $self->id;
          $self->dbobject->{ref_key}        = $self->ref_key;
          $self->dbobject->{file_class}     = $self->file_class;
          $self->dbobject->{src_class}      = $self->src_class;
          $self->dbobject->{dbobject}       = $self->dbobject;
          $self->dbobject->{x_info}         = $self->x_info;
    }
    $self->dbobject->exec_method($args);

}

=head1 COPYRIGHT

Copyright (C) 2011 The LedgerSMB Core Team

This file is licensed under the Gnu General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

1;
