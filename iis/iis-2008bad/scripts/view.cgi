#!/usr/bin/perl -w

use strict;
use DBI;
use CGI;

my $q = new CGI;
my $dbh = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
print "Content-type: text/html\n\n";
my $sth = $dbh->prepare("SELECT id, name, sellername, sequencenumber FROM items WHERE status = 'Ready' order by sequencenumber");
$sth->execute;
my @header = ('ID', 'Item Description', 'Donor Name', 'Order');
print '<table><tr><td>', join('</td><td>', map { "<b>$_</b>" } @header), "</td></tr>\n";
while ( my $row = $sth->fetchrow_hashref ) {
	my @row = map { $row->{$_} } qw/id name sellername sequencenumber/;
	print '<tr><td>', join('</td><td>', @row), '</td></tr>';
}
print "</table>\n";
$sth->finish;
