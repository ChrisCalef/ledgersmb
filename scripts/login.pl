package LedgerSMB::Scripts::login;
our $VERSION = 1.0;

use LedgerSMB::Locale;
use LedgerSMB::Form; # Required for now to integrate with menu module.
use LedgerSMB::User;
use LedgerSMB::Auth;
use strict;

sub __default {
   my ($request) = @_;
    my $locale;
    $locale = LedgerSMB::Locale->get_handle(${LedgerSMB::Sysconfig::language})
      or $request->error( __FILE__ . ':' . __LINE__ . 
         ": Locale not loaded: $!\n" );
    my $template = LedgerSMB::Template->new(
        user =>$request->{_user}, 
        locale => $locale,
        path => 'UI',
        template => 'login',
        format => 'HTML'
    );
    $template->render($request);
}

sub authenticate {
    my ($request) = @_;
    if (!$request->{dbh}){
        if (!$request->{company}){
             $request->{company} = $LedgerSMB::Sysconfig::default_db;
        }
        $request->_db_init;
    }
    my $path = $ENV{SCRIPT_NAME};
    $path =~ s|[^/]*$||;
    if ($request->{dbh} || $request->{log_out}){
        print "Content-Type: text/html\n";
        print "Set-Cookie: LedgerSMB=Login; path=$path\n";
	print "Status: 200 Success\n\n";
        if ($request->{log_out}){
            exit;
        }
    }
    else {
        print "WWW-Authenticate: Basic realm=\"LedgerSMB\"\n";
        print "Status: 401 Unauthorized\n\n";
	print "Please enter your credentials.\n";
        exit; 
    }
}

sub login {
    my ($request) = @_;
    
    if (!$request->{_user}){
        __default($request);
    }
    require "scripts/menu.pl";
    LedgerSMB::Scripts::menu::root_doc($request);

}

sub logout {
    my ($request) = @_;
    $request->{callback}   = "";
    $request->{endsession} = 1;
    LedgerSMB::Auth::session_destroy($request);
    print "Location: login.pl\n";
    print "Content-type: text/html\n\n";
    exit;
}
    
1;
