#!/usr/bin/perl

use strict;
use warnings;
use Test::More 'no_plan';
use Test::Exception;
use Test::Trap qw(trap $trap);
use Math::BigFloat;

use LedgerSMB;

##line	subroutine
##108	new
##235	redirect
##254	format_amount
##364	parse_amount
##408	round_amount
##423	call_procedure
##454	date_to_number
##490	db_init
##522	redo_rows
##547	merge

my $lsmb = new LedgerSMB;
my %myconfig;
my $utfstr;
my @r;

ok(defined $lsmb);
isa_ok($lsmb, 'LedgerSMB');

# $lsmb->escape checks
$lsmb = new LedgerSMB;
$utfstr = "\xd8\xad";
utf8::decode($utfstr);
ok(!$lsmb->escape, 'escape: (undef)');
ok(!$lsmb->escape('foo' => 'bar'), 'escape: (invalid args)');
cmp_ok($lsmb->escape('string' => ' '), 'eq', '%20',
	'escape: \' \'');
cmp_ok($lsmb->escape('string' => 'foo'), 'eq', 'foo', 
	'escape: foo');
cmp_ok($lsmb->escape('string' => 'foo bar'), 'eq', 'foo%20bar', 
	'escape: foo bar');
TODO: {
	local $TODO = 'Fun with Unicode';
	cmp_ok($lsmb->escape('string' => $utfstr), 'eq', '%d8%ad', 
		'escape: U+D8AD');
}

# $lsmb->is_blank checks
$lsmb = new LedgerSMB;
$lsmb->{blank} = '    ';
$lsmb->{notblank} = ' d   ';
TODO: {
	local $TODO = 'Errors should be thrown';
	throws_ok{$lsmb->is_blank} 'Error::Simple', 'is_blank: (undef)';
	throws_ok{$lsmb->is_blank('foo' => 'bar')} 'Error::Simple', 
		'is_blank: (invalid args)';
}
is($lsmb->is_blank('name' => 'notblank'), 0, 'is_blank: notblank');
is($lsmb->is_blank('name' => 'blank'), 1, 'is_blank: blank');

# $lsmb->is_run_mode checks
$lsmb = new LedgerSMB;
$ENV{GATEWAY_INTERFACE} = 'foo';
is($lsmb->is_run_mode('cgi'), 1, 'is_run_mode: CGI - CGI');
is($lsmb->is_run_mode('cli'), 0, 'is_run_mode: CGI - CLI');
is($lsmb->is_run_mode('mod_perl'), 0, 'is_run_mode: CGI - mod_perl');
is($lsmb->is_run_mode('foo'), 0, 'is_run_mode: CGI - (bad mode)');
is($lsmb->is_run_mode, 0, 'is_run_mode: CGI - (unknown mode)');
$ENV{MOD_PERL} = 'foo';
is($lsmb->is_run_mode('cgi'), 1, 'is_run_mode: CGI/mod_perl - CGI');
is($lsmb->is_run_mode('cli'), 0, 'is_run_mode: CGI/mod_perl - CLI');
is($lsmb->is_run_mode('mod_perl'), 1, 'is_run_mode: CGI/mod_perl - mod_perl');
is($lsmb->is_run_mode('foo'), 0, 'is_run_mode: CGI/mod_perl - (bad mode)');
is($lsmb->is_run_mode, 0, 'is_run_mode: CGI/mod_perl - (unknown mode)');
delete $ENV{GATEWAY_INTERFACE};
is($lsmb->is_run_mode('cgi'), 0, 'is_run_mode: mod_perl - CGI');
is($lsmb->is_run_mode('cli'), 0, 'is_run_mode: mod_perl - CLI');
is($lsmb->is_run_mode('mod_perl'), 1, 'is_run_mode: mod_perl - mod_perl');
is($lsmb->is_run_mode('foo'), 0, 'is_run_mode: mod_perl - (bad mode)');
is($lsmb->is_run_mode, 0, 'is_run_mode: mod_perl - (unknown mode)');
delete $ENV{MOD_PERL};
is($lsmb->is_run_mode('cgi'), 0, 'is_run_mode: CLI - CGI');
is($lsmb->is_run_mode('cli'), 1, 'is_run_mode: CLI - CLI');
is($lsmb->is_run_mode('mod_perl'), 0, 'is_run_mode: CLI - mod_perl');
is($lsmb->is_run_mode('foo'), 0, 'is_run_mode: CLI - (bad mode)');
is($lsmb->is_run_mode, 0, 'is_run_mode: CLI - (unknown mode)');

# $lsmb->num_text_rows checks
$lsmb = new LedgerSMB;
is($lsmb->num_text_rows('string' => "apple\npear", 'cols' => 10, 'max' => 5),
	2, 'num_text_rows: 2 rows, no column breakage, max 5 rows');
is($lsmb->num_text_rows('string' => "apple\npear", 'cols' => 10, 'max' => 1),
	1, 'num_text_rows: 2 rows, no column breakage, max 1 row');
is($lsmb->num_text_rows('string' => "apple\npear", 'cols' => 10, 'max' => 2),
	2, 'num_text_rows: 2 rows, no column breakage, max 2 rows');
is($lsmb->num_text_rows('string' => "apple\npear", 'cols' => 10),
	2, 'num_text_rows: 2 rows, no column breakage, no max row count');
is($lsmb->num_text_rows('string' => "01234567890123456789", 'cols' => 10),
	2, 'num_text_rows: 2 rows, non-word column breakage, no max row count');
is($lsmb->num_text_rows('string' => "012345 67890123 456789", 'cols' => 10),
	3, 'num_text_rows: 3 rows, word column breakage, no max row count');
is($lsmb->num_text_rows('string' => "0123456789", 'cols' => 10),
	1, 'num_text_rows: 1 rows, no breakage, max cols, no max row count');
is($lsmb->num_text_rows('string' => "01234567890", 'cols' => 10),
	2, 'num_text_rows: 2 rows, no breakage, max cols+1, no max row count');
is($lsmb->num_text_rows('string' => "1\n\n2", 'cols' => 10),
	3, 'num_text_rows: 3 rows, no breakage, blank line, no max row count');
is($lsmb->num_text_rows('string' => "012345 67890123456789", 'cols' => 10),
	3, 'num_text_rows: 3 rows, word and non column breakage, no max row count');

# $lsmb->debug checks
$lsmb = new LedgerSMB;
@r = trap{$lsmb->debug($lsmb)};
like($trap->stdout, qr|\n\$VAR1 = bless\( {[\n\s]+'action' => '',[\n\s]+'dbversion' => '\d+\.\d+\.\d+',[\n\s]+'path' => 'bin/mozilla',[\n\s]+'version' => '$lsmb->{version}'[\n\s]+}, 'LedgerSMB' \);|,
	'debug: $lsmb, no file');
SKIP: {
	skip 'Environment for file test not clean' if -f "t/var/lsmb-11.$$";
	$lsmb->{file} = "t/var/lsmb-11.$$";
	$lsmb->debug('file' => $lsmb->{file}, $lsmb);
	ok(-f "t/var/lsmb-11.$$", "debug: output file t/var/lsmb-11.$$ created");
	open(my $FH, '<', "t/var/lsmb-11.$$");
	my @str = <$FH>;
	close($FH);
	chomp(@str);
	like(join("\n", @str), qr|\$VAR1 = 'file';\n\$VAR2 = 't/var/lsmb-11.$$';\n\$VAR3 = bless\( {[\n\s]+'action' => '',[\n\s]+'dbversion' => '\d+\.\d+\.\d+',[\n\s]+'file' => 't/var/lsmb-11.$$',[\n\s]+'path' => 'bin/mozilla',[\n\s]+'version' => '$lsmb->{version}'[\n\s]+}, 'LedgerSMB' \);|,
		'debug: $lsmb with file, contents');
	is(unlink("t/var/lsmb-11.$$"), 1, "debug: removing t/var/lsmb-11.$$");
	ok(!-e "t/var/lsmb-11.$$", "debug: t/var/lsmb-11.$$ removed");
};
