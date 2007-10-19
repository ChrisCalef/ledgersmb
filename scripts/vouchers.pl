#!/usr/bin/perl

# This file is copyright (C) 2007the LedgerSMB core team and licensed under 
# the GNU General Public License.  For more information please see the included
# LICENSE and COPYRIGHT files

package LedgerSMB::Scripts::vouchers;
our $VERSION = '0.1';

$menufile = "menu.ini";
use LedgerSMB::Batch;
use LedgerSMB::Voucher;
use LedgerSMB::Template;
use strict;

sub create_batch {
    my ($request) = @_;
    $request->{hidden} = [
        {name => "batch_type", value => $request->{batch_type}},
    ];
    my $template = LedgerSMB::Template->new(
        user =>$request->{_user}, 
        locale => $request->{_locale},
        path => 'UI',
        template => 'create_batch',
        format => 'HTML'
    );
    $template->render($request);
}

sub create_vouchers {
    #  This function is not safe for caching as long as the scripts are in bin.
    #  This is because these scripts import all functions into the *current*
    #  namespace.  People using fastcgi and modperl should *not* cache this 
    #  module at the moment. -- CT
    my ($request) = shift @_;
    use LedgerSMB::Form;

    my $batch = LedgerSMB::Batch->new({base => $request});
    $batch->create;

    my $vouchers_dispatch = 
    {
        payable    => {script => 'bin/ap.pl', function => sub {add()}},
        receivable => {script => 'bin/ar.pl', function => sub {add()}},
        payments   => {script => 'bin/cp.pl', function => sub {payments()}},
        receipts   => {script => 'bin/cp.pl', function => sub {receipts()}},
        gl         => {script => 'bin/gl.pl', function => sub {add()}},
    };

    # Note that the line below is generally considered incredibly bad form. 
    # However, the code we are including is going to require it for now.
    no strict;
    our $form = new Form;
    our $locale = $request->{_locale};
    for (keys %$request){
        $form->{$_} = $request->{$_};
    }

    $form->{approved} = 0;
    $form->{transdate} = $request->{batch_date};
    print STDERR "$request->{batch_type}\n";
    require $vouchers_dispatch->{$request->{batch_type}}{script};

    my $script = $vouchers_dispatch->{$request->{batch_type}}{script};
    $script =~ s|.*/||;
    $form->{script} = $script;

\    $vouchers_dispatch->{$request->{batch_type}}{function}();
}

sub list_vouchers {
}

sub approve_batch {
}

sub delete_batch {
}

1;
