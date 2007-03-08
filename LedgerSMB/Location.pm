=head1 NAME

LedgerSMB::Location - LedgerSMB class for managing Business Locations

=head1 SYOPSIS

This module creates object instances based on LedgerSMB's in-database ORM.  

=head1 METHODS

The following method is static:
=item new ($LedgerSMB object);

The following methods are passed through to stored procedures:
=item save
=item get
=item search
=item list_all
=item delete (via Autoload)

The above list may grow over time, and may depend on other installed modules.

=head1 Copyright (C) 2007, The LedgerSMB core team.
This file is licensed under the Gnu General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=back

=cut

package LedgerSMB::Location;
use LedgerSMB;
use LedgerSMB::DBObject;
@ISA = (LedgerSMB::DBObject);

sub AUTOLOAD {
	my $procname = "location_$LedgerSMB::Location::Autoload";
	$self->exec_method($procname);
}

sub save {
	$ref = shift @{$self->exec_method("location_save")};
	$self->merge($ref, 'id');
}

sub get {
	$ref = shift @{$self->exec_method('location_get')};
	$self->merge($ref, keys $ref);
}

sub search {
	$self->{search_results} = $self->exec_method('location_search');
}

sub list_all {
	$self->{search_results} = $self->exec_method('location_list_all');
}
