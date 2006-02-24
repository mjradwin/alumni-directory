#
# $Id: aid_newutil.pm,v 1.5 2006/02/23 22:50:46 mradwin Exp $
#
# Copyright (c) 2006  Michael J. Radwin.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
#  * Redistributions of source code must retain the above
#    copyright notice, this list of conditions and the following
#    disclaimer.
#
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials
#    provided with the distribution.
#
#  * Neither the name of the High School Alumni Internet Directory
#    nor the names of its contributors may be used to endorse or
#    promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use strict;
use aid_util ();
use DBI ();

package aid_newutil;

my $connected = 0;
my $dbh;

sub db_connect {
    if (!$connected) {
	my $dbname = aid_util::config("dbname");
	my $dbhost = aid_util::config("dbhost");
	my $dsn = "DBI:mysql:database=$dbname;host=$dbhost";
	$dbh = DBI->connect($dsn,
			    aid_util::config("dbuser"),
			    aid_util::config("dbpass"))
	    or die $DBI::errstr;
	$connected = 1;
    }

    $dbh;
}

sub load_years {
    my($dbh) = @_;

    my $sql = qq{
SELECT DISTINCT entry_gradclass FROM aid_entry
WHERE entry_gradclass IS NOT NULL
};
    my $sth = $dbh->prepare($sql);
    $sth->execute or die $sth->errstr;
    my $yearsref = $sth->fetchall_arrayref([0]);
    my @years = map { $_->[0] } @{$yearsref};

    # are there any "other" alumni?
    $sql = qq{
SELECT COUNT(entry_affil_other) from aid_entry
WHERE entry_affil_other IS NOT NULL
};
    $sth = $dbh->prepare($sql);
    $sth->execute or die $sth->errstr;
    my($count) = $sth->fetchrow_array;
#    push(@years, "other") if $count;

    @years;
}

sub load_records
{
    my($dbh,$extra_sql) = @_;

    $extra_sql = "" unless defined $extra_sql;

    my %result;
    my $sql = <<EOSQL
SELECT
a.alumnus_id,a.alumnus_status,
UNIX_TIMESTAMP(a.alumnus_create),
UNIX_TIMESTAMP(a.alumnus_update),
e.entry_name_surname,e.entry_name_married,
e.entry_name_given,e.entry_name_mi,
e.entry_email,e.entry_gradclass,e.entry_affil_other,
e.entry_web_page,e.entry_location,e.entry_note,e.entry_reunion
FROM aid_alumnus a, aid_entry e
WHERE a.alumnus_entry_id = e.entry_id
$extra_sql
EOSQL
;

    if ($ENV{"AID_DEBUG"}) {
	warn $sql;
    }

    my $sth = $dbh->prepare($sql);
    $sth->execute or die $sth->errstr;
    while (my($id,$status,$ts_create,$ts_update,
	      $name_surname,$name_married,
	      $name_given,$name_mi,
	      $email,$gradclass,$affil_other,
	      $web_page,$location,$note_text,$reunion) =
	   $sth->fetchrow_array)
    {
	my $yr = $gradclass ? $gradclass : $affil_other;
	my %rec = (
		   "id" => $id,
		   "v" => $status,
		   "sn" => $name_surname,
		   "mn" => $name_married,
		   "gn" => $name_given,
		   "mi" => $name_mi,
		   "q" => 4,
		   "r" => $reunion,
		   "b" => 0,
		   "c" => $ts_create,
		   "u" => $ts_update,
		   "f" => 0,
		   "yr" => $yr,
		   "e" => $email,
		   "w" => $web_page,
		   "l" => $location,
		   "n" => $note_text,
		   );

	foreach my $key (@aid_util::edit_field_names, "n") {
	    $rec{$key} = "" unless defined $rec{$key};
	}

	$result{$id} = \%rec;
    }

    \%result;
}

1;
