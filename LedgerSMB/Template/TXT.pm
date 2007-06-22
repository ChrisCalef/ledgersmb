
=head1 NAME

LedgerSMB::Template::TXT  Template support module for LedgerSMB

=head1 METHODS

=over

=item get_template ($name)

Returns the appropriate template filename for this format.

=item preprocess ($vars)

Returns $vars.

=item process ($parent, $cleanvars)

Processes the template for text.

=item postprocess ($parent)

Returns the output filename.

=back

=head1 Copyright (C) 2007, The LedgerSMB core team.

This work contains copyrighted information from a number of sources all used
with permission.  

It is released under the GNU General Public License Version 2 or, at your 
option, any later version.  See COPYRIGHT file for details.  For a full list 
including contact information of contributors, maintainers, and copyright 
holders, see the CONTRIBUTORS file.
=cut

package LedgerSMB::Template::TXT;

use Error qw(:try);
use Template;
use LedgerSMB::Template::TTI18N;

sub get_template {
    my $name = shift;
    return "${name}.txt";
}

sub preprocess {
    my $rawvars = shift;
    return $rawvars;
}

sub process {
	my $parent = shift;
	my $cleanvars = shift;
	my $template;

	$template = Template->new({
		INCLUDE_PATH => $parent->{include_path},
		START_TAG => quotemeta('<?lsmb'),
		END_TAG => quotemeta('?>'),
		DELIMITER => ';',
		}) || throw Error::Simple Template->error(); 

	if (not $template->process(
		get_template($parent->{template}), 
		{%$cleanvars, %$LedgerSMB::Template::TTI18N::ttfuncs,
			'escape' => \&preprocess},
		"$parent->{outputfile}.txt", binmode => ':utf8')) {
		throw Error::Simple $template->error();
	}
	$parent->{mimetype} = 'text/plain';
}

sub postprocess {
    my $parent = shift;
    $parent->{rendered} = "$parent->{outputfile}.txt";
    return "$parent->{outputfile}.txt";
}

1;
