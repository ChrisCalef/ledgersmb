#=====================================================================
# LedgerSMB 
# Small Medium Business Accounting software
# http://www.ledgersmb.org/
# 
#
# Copyright (C) 2006
# This work contains copyrighted information from a number of sources all used
# with permission.  It is released under the GNU General Public License 
# Version 2 or, at your option, any later version.  See COPYRIGHT file for 
# details.
#
#
#======================================================================
#
# This file has undergone whitespace cleanup.
#
#======================================================================
# This package contains session related functions:
#
# check - checks validity of session based on the user's cookie and login
#
# create - creates a new session, writes cookie upon success
#
# destroy - destroys session
#
# password_check - compares the password with the stored cryted password 
#                  (ver. < 1.2) and the md5 one (ver. >= 1.2)
#====================================================================
package Session;

sub session_check {

	my ($cookie, $form) = @_;
	my ($sessionid, $token) = split /:/, $cookie;

	# use the central database handle
	my $dbh = ${LedgerSMB::Sysconfig::GLOBALDBH}; 

	my $checkQuery = $dbh->prepare("SELECT sl_login FROM session WHERE session_id = ? AND token = ? AND last_used > now() - ?::interval");

	my $updateAge = $dbh->prepare("UPDATE session SET last_used = now() WHERE session_id = ?;");

	#must be an integer
	$sessionid =~ s/[^0-9]//g;
	$sessionid = int $sessionid;

	#must be 32 chars long and contain hex chars
	$token =~ s/[^0-9a-f]//g;
	$token = substr($token, 0, 32);

	if (!$myconfig{timeout}){
		$timeout = "1 day";
	} else {
		$timeout = "$myconfig{timeout} seconds";
	}

	$checkQuery->execute($sessionid, $token, $timeout) 
		|| $form->dberror(__FILE__.':'.__LINE__.': Looking for session: ');
	my $sessionValid = $checkQuery->rows;

	if($sessionValid){

		#user has a valid session cookie, now check the user
		my ($sessionLogin) = $checkQuery->fetchrow_array;

		my $login = $form->{login};
		$login =~ s/[^a-zA-Z0-9@.-]//g;

		if($sessionLogin eq $login){
			$updateAge->execute($sessionid) || $form->dberror(__FILE__.':'.__LINE__.': Updating session age: ');
			return 1;

		} else {
			#something's wrong, they have the cookie, but wrong user. Hijack attempt?
			#delete the cookie in the browser
			print qq|Set-Cookie: LedgerSMB=; path=/;\n|;
			return 0;
		}
	
	} else {
		#cookie is not valid
		#delete the cookie in the browser
		print qq|Set-Cookie: LedgerSMB=; path=/;\n|;
		return 0;
	}
}

sub session_create {
	my ($form) = @_;

	if (! $ENV{HTTP_HOST}){
		#don't create cookies or sessions for CLI use
		return 1;
	}

	# use the central database handle
	my $dbh = ${LedgerSMB::Sysconfig::GLOBALDBH}; 

	# TODO Change this to use %myconfig
	my $deleteExisting = $dbh->prepare("DELETE FROM session WHERE sl_login = ? AND age(last_used) > ?::interval");  

	my $seedRandom = $dbh->prepare("SELECT setseed(?);");

	my $fetchSequence = $dbh->prepare("SELECT nextval('session_session_id_seq'), md5(random());");
	
	my $createNew = $dbh->prepare("INSERT INTO session (session_id, sl_login, token) VALUES(?, ?, ?);");


	# this is assuming that $form->{login} is safe, which might be a bad assumption
	# so, I'm going to remove some chars, which might make previously valid logins invalid
	my $login = $form->{login};
	$login =~ s/[^a-zA-Z0-9@.-]//g;

	#delete any existing stale sessions with this login if they exist
	if (!$myconfig{timeout}){
	   $myconfig{timeout} = 86400;
	}

	$deleteExisting->execute($login, "$myconfig{timeout} seconds") || $form->dberror(__FILE__.':'.__LINE__.': Delete from session: ');

	#doing the random stuff in the db so that LedgerSMB won't
	#require a good random generator - maybe this should be reviewed, pgsql's isn't great either
	$fetchSequence->execute() || $form->dberror(__FILE__.':'.__LINE__.': Fetch sequence id: ');
	my ($newSessionID, $newToken) = $fetchSequence->fetchrow_array;

	#create a new session
	$createNew->execute($newSessionID, $login, $newToken) || $form->dberror(__FILE__.':'.__LINE__.': Create new session: ');

	#reseed the random number generator
	my $randomSeed = 1.0 * ('0.'. (time() ^ ($$ + ($$ <<15))));
	$seedRandom->execute($randomSeed)|| $form->dberror(__FILE__.':'.__LINE__.': Reseed random generator: ');

	$newCookieValue = $newSessionID . ':' . $newToken;

	#now set the cookie in the browser
	#TODO set domain from ENV, also set path to install path
	print qq|Set-Cookie: LedgerSMB=$newCookieValue; path=/;\n|;
	$form->{LedgerSMB} = $newCookieValue;
}

sub session_destroy {

	my ($form) = @_;

	my $login = $form->{login};
	$login =~ s/[^a-zA-Z0-9@.-]//g;

	# use the central database handle
	my $dbh = ${LedgerSMB::Sysconfig::GLOBALDBH};

	my $deleteExisting = $dbh->prepare("DELETE FROM session WHERE sl_login = ?;");
	$deleteExisting->execute($login) || $form->dberror(__FILE__.':'.__LINE__.': Delete from session: ');

	#delete the cookie in the browser
	print qq|Set-Cookie: LedgerSMB=; path=/;\n|;

}

sub password_check {

	use Digest::MD5;

	my ($form, $username, $password) = @_;

	# use the central database handle
	my $dbh = ${LedgerSMB::Sysconfig::GLOBALDBH};

	my $fetchPassword = $dbh->prepare("SELECT uc.password, uc.crypted_password
										 FROM users as u, users_conf as uc
										WHERE u.username = ?
										  AND u.id = uc.id;");

	$fetchPassword->execute($username) || $form->dberror(__FILE__.':'.__LINE__.': Fetching password : ');

	my ($md5Password, $cryptPassword) = $fetchPassword->fetchrow_array;

	if ($cryptPassword){
		#First time login from old system, check crypted password

		if ((crypt $password, substr($username, 0, 2)) eq $cryptPassword) {	

			#password was good, convert to md5 password and null crypted
			my $updatePassword = $dbh->prepare("UPDATE users_conf
												   SET password = md5(?),
													   crypted_password = null
												  FROM users
												 WHERE users_conf.id = users.id
												   AND users.username = ?;");

			$updatePassword->execute($password, $username) || $form->dberror(__FILE__.':'.__LINE__.': Converting password : ');

			return 1;

		} else {
			return 0; #password failed
		}

	}elsif ($md5Password){

		if ($md5Password ne (Digest::MD5::md5_hex $password) ) {
			return 0;
		}
		else{
			return 1;
		}
	
	} else {
		#both the md5Password and cryptPasswords were blank
		return 0;
	}
}

1;
