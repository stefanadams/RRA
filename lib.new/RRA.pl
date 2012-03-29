# Call PerlModule Apache::DBI in httpd.conf

use strict;
use CGI ();
CGI->compile(':all');
use Apache::DBI ();
use Carp ();
Apache::DBI->connect("DBI:mysql:test::localhost", "", "",{PrintError=>1,RaiseError=>0,AutoCommit=>1}) or die "Cannot connect to database: $DBI::errstr";
