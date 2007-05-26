
=head1 NAME

LedgerSMB::Template::PS  Template support module for LedgerSMB

=head1 METHODS

=over

=item get_template ($name)

Returns the appropriate template filename for this format.

=item preprocess ($vars)

Currently does nothing.

=item process ($parent, $cleanvars)

Processes the template for Postscript.

=item postprocess ($parent)

Currently does nothing.

=back

=head1 Copyright (C) 2007, The LedgerSMB core team.

This work contains copyrighted information from a number of sources all used
with permission.  

It is released under the GNU General Public License Version 2 or, at your 
option, any later version.  See COPYRIGHT file for details.  For a full list 
including contact information of contributors, maintainers, and copyright 
holders, see the CONTRIBUTORS file.
=cut

package LedgerSMB::Template::PS;

use Error qw(:try);
use Template::Latex;

sub get_template {
	my $name = shift;
	return "${name}.tex";
}

sub preprocess {
	my $rawvars = shift;
	my $vars;
	my $type = ref $rawvars;
	return $vars;
}

sub process {
	my $parent = shift;
	my $cleanvars = shift;
	my $template;

	$template = Template::Latex->new({
		LATEX_FORMAT => 'ps',
		INCLUDE_PATH => $parent->{include_path},
		START_TAG => quotemeta('<?lsmb'),
		END_TAG => quotemeta('?>'),
		DELIMITER => ';',
		}) || throw Error::Simple Template::Latex->error(); 

	if (not $template->process(
		get_template($parent->{template}), 
		$cleanvars, "$parent->{outputfile}.ps", binmode => ':utf8')) {
		throw Error::Simple $template->error();
	}
	$parent->{mimetype} = 'application/postscript';
}

sub postprocess {
	my $parent = shift;
	$parent->{rendered} = "$parent->{outputfile}.ps";
	return "$parent->{outputfile}.ps";
}

1;
