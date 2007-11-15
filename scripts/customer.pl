#!/usr/bin/perl

=pod

=head1 NAME

LedgerSMB::Scripts::customer - LedgerSMB class defining the Controller
functions, template instantiation and rendering for customer editing and display.

=head1 SYOPSIS

This module is the UI controller for the customer DB access; it provides the 
View interface, as well as defines the Save customer. 
Save customer will update or create as needed.


=head1 METHODS

=cut

package LedgerSMB::Scripts::customer;

use LedgerSMB::Template;
use LedgerSMB::DBObject::Customer;

require 'lsmb-request.pl';

=pod

=over

=item get($self, $request, $user)

Requires form var: id

Extracts a single customer from the database, using its company ID as the primary
point of uniqueness. Shows (appropriate to user privileges) and allows editing
of the customer informations.

=back

=cut

sub get {
    
    my ($request) = @_;
    my $customer = LedgerSMB::DBObject::Company->new(base => $request, copy => 'all');
    
    $customer->set( entity_class=> '2' );
    my $result = $customer->get();
    
    my $template = LedgerSMB::Template->new( user => $user, 
	template => 'Customer/customer.html', language => $user->{language}, 
        format => 'html');
    $template->render($results);
        
}

=pod

=over

=item add

This method creates a blank screen for entering a customer's information.

=back

=cut 

sub add {
    my ($request) = @_;
    my $customer = LedgerSMB::DBObject::Company->new(base => $request, copy => 'all');
    $customer->set(entity_class=>2);
    my $template = LedgerSMB::Template->new( user => $user, 
	template => 'Customer/customer.html', language => $user->{language}, 
        format => 'html');
    $template->render($results);
}

=pod

=over

=item search($self, $request, $user)

Requires form var: search_pattern

Directly calls the database function search, and returns a set of all customers
found that match the search parameters. Search parameters search over address 
as well as customer/Company name.

=back

=cut

sub search {
    my ($request) = @_;
    
    if ($request->type() eq 'POST') {
        # assume it's asking us to do the search, now
        
        my $customer = LedgerSMB::DBObject::Company->new(base => $request, copy => 'all');
        $customer->set(entity_class=>2);
        my $results = $customer->search($customer->{search_pattern});

        my $template = LedgerSMB::Template->new( user => $user, 
    	template => 'Customer/customer.html', language => $user->{language}, 
            format => 'html');
        $template->render($results);
        
    }
    else {
        
        # grab the happy search page out.
        
        my $template = LedgerSMB::Template->new( user => $user, 
    	template => 'Customer/customer_search.html', language => $user->{language}, 
            format => 'html');
            
        $template->render();
    }
}

=pod

=over

=item save($self, $request, $user)

Saves a customer to the database. The function will update or insert a new 
customer as needed, and will generate a new Company ID for the customer if needed.

=back

=cut

sub save {
    
    my ($request) = @_;
    
    if ($request->type() == 'POST') {
        
        my $customer = LedgerSMB::DBObject::Customer->get(base=>$request, copy=>'all');
        
        unless ($customer) {
            
            $customer = LedgerSMB::DBObject::Customer->new(base=>$reqest, copy=>'all');
        }
        
        my $result = $customer->save();

        my $template = LedgerSMB::Template->new( user => $user, 
    	template => 'Customer/customer.html', language => $user->{language}, 
            format => 'html');
        $template->render($result);
    } 
    else {
        
    }
}

1;
