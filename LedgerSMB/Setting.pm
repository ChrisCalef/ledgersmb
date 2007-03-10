=head1 NAME

LedgerSMB::Setting - LedgerSMB class for managing Business Locations

=head1 SYOPSIS

This module creates object instances based on LedgerSMB's in-database ORM.  

=head1 METHODS

The following method is static:
=item new ($LedgerSMB object);

The following methods are passed through to stored procedures:
=item get ($self->{key})
=item set ($self->{key}, $self->{value})
=item get_default_accounts()

The above list may grow over time, and may depend on other installed modules.

=head1 Copyright (C) 2007, The LedgerSMB core team.
This file is licensed under the Gnu General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=back

=cut

package LedgerSMB::Setting;
use LedgerSMB;
use LedgerSMB::DBObject;
our $VERSION = '1.0.0';

our @ISA = qw(LedgerSMB::DBObject);

sub AUTOLOAD {
	my $self = shift;
	$AUTOLOAD =~ s/^.*:://;
	my $procname = "setting_$AUTOLOAD";
	$self->exec_method($procname, @_);
}

sub get {
	$self = shift;
	$hashref = @{$self->exec_method('setting_get');
	$self->merge($hashref, 'value');

sub parse {

	$self = shift;

	# Long-run, we may want to run this via Parse::RecDescent, but this is
	# at least a start for here.  Chris T.

	# Replaces Form::UpdateDefaults

	$_ = $self->incriment;
	# check for and replace
	# <?lsmb DATE ?>, <?lsmb YYMMDD ?>, <?lsmb YEAR ?>, <?lsmb MONTH ?>, <?lsmb DAY ?> or variations of
	# <?lsmb NAME 1 1 3 ?>, <?lsmb BUSINESS ?>, <?lsmb BUSINESS 10 ?>, <?lsmb CURR... ?>
	# <?lsmb DESCRIPTION 1 1 3 ?>, <?lsmb ITEM 1 1 3 ?>, <?lsmb PARTSGROUP 1 1 3 ?> only for parts
	# <?lsmb PHONE ?> for customer and vendors

	my $dbvar = $_;
	my $var = $_;
	my $str;
	my $param;

	if (/<\?lsmb /) {

		while (/<\?lsmb /) {

			s/<\?lsmb .*? \?>//;
			last unless $&;
		$param = $&;
			$str = "";

			if ($param =~ /<\?lsmb date \?>/i) {
				$str = ($self->split_date($myconfig->{dateformat}, $self->{transdate}))[0];
				$var =~ s/$param/$str/;
			}

			if ($param =~ /<\?lsmb (name|business|description|item|partsgroup|phone|custom)/i) {

				my $fld = lc $&;
				$fld =~ s/<\?lsmb //;

				if ($fld =~ /name/) {
					if ($self->{type}) {
						$fld = $self->{vc};
					}
				}

				my $p = $param;
				$p =~ s/(<|>|%)//g;
				my @p = split / /, $p;
				my @n = split / /, uc $self->{$fld};

				if ($#p > 0) {

					for (my $i = 1; $i <= $#p; $i++) {
						$str .= substr($n[$i-1], 0, $p[$i]);
					}

				} else {
					($str) = split /--/, $self->{$fld};
				}

				$var =~ s/$param/$str/;
				$var =~ s/\W//g if $fld eq 'phone';
			}

			if ($param =~ /<\?lsmb (yy|mm|dd)/i) {

				my $p = $param;
				$p =~ s/(<|>|%)//g;
				my $spc = $p;
				$spc =~ s/\w//g;
				$spc = substr($spc, 0, 1);
				my %d = ( yy => 1, mm => 2, dd => 3 );
				my @p = ();

				my @a = $self->split_date($myconfig->{dateformat}, $self->{transdate});
				for (sort keys %d) { push @p, $a[$d{$_}] if ($p =~ /$_/) }
				$str = join $spc, @p;
				$var =~ s/$param/$str/;
			}

			if ($param =~ /<\?lsmb curr/i) {
				$var =~ s/$param/$self->{currency}/;
			}
		}
	}

	$self->{value} = $var;
	$var;
}

