#!/usr/bin/perl

use warnings;
use strict;
use DBI;
use CGI;
use Date::Manip;
use Spreadsheet::WriteExcel;

my %night = (
	'2008-03-24' => 1,
	'2008-03-25' => 2,
	'2008-03-26' => 3,
	'2008-03-27' => 4,
);
my @columns = qw/id item value donor bidder bphone amount night timesold/;
my $select = "SELECT * FROM (SELECT items.id AS id, items.name AS item, items.suggestedprice AS value, items.sellername AS donor, items.status AS status, bidders.name AS bidder, bidders.phone AS bphone, items.bid AS amount, items.bhtimestamp AS timesold FROM bidhistory JOIN items ON bidhistory.itemid=items.id JOIN bidders ON bidhistory.bidderid=bidders.bidderid WHERE status='Complete' ORDER BY bidnum DESC) AS t1 GROUP BY id";

my $q = new CGI;
my $orderby = $q->param('orderby') || $ENV{orderby} || 'id';
my $numericsort = $q->param('orderby') || $ENV{numericsort} || 0;
my $dbh = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY $orderby");
$sth->execute;
my $report = {};
while ( my $row = $sth->fetchrow_hashref ) {
	no warnings;
	my $date = UnixDate(ParseDate($row->{timesold}), '%Y-%m-%d');
	$row->{night} = $night{$date};
	my $key = $numericsort ? $row->{id} : "$row->{$orderby}:$row->{id}";
	$report->{$row->{night}}->{$key} = $row;
}
$sth = $dbh->prepare("select count(id) AS bellringers from items where bid >= suggestedprice");
$sth->execute;
my $bellringers = 0;
while ( my $row = $sth->fetchrow_hashref ) {
	no warnings;
	$bellringers = $row->{bellringers};
}
$sth->finish;

if ( $ARGV[0] ) {
	foreach ( map { $_ if $report->{$_}->{$ARGV[0]} } keys %{$report} ) {
		no warnings;
		next unless $_;
		my $row = $report->{$_}->{$ARGV[0]};
		$row->{bphone} =~ s/^(\d{3})(\d{3})(\d{4})$/\($1\) $2-$3/;
		print "Item: $row->{id} / $row->{item}\n";
		print "Winner: $row->{bidder} / $row->{bphone}\n";
		print "Winning Bid: $row->{amount}\n";
	}
} else {
	my $c = 0;
	my $sum = 0;
	my $value = 0;
	foreach my $night ( sort keys %{$report} ) {
		my $cn = 0;
		my $sumn = 0;
		my $valuen = 0;
		@_ = $numericsort ? sort { int($a) <=> int($b) } keys %{$report->{$night}} : sort keys %{$report->{$night}};
		foreach my $key ( @_ ) {
			$c++; $cn++;
			my $row = $report->{$night}->{$key};
			$sum+=$row->{amount}; $sumn+=$row->{amount};
			$value+=$row->{value}; $valuen+=$row->{value};
#			print swrite("\@>>| \@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<| \@<<<<<<<<<<<<<<<<<<| \@<<<<<<<<<| \@>>>\n",
#			map { $row->{$_} } qw/id item bidder bphone amount/);
		}
		print "Night $night: $cn items / \$$sumn ($valuen)\n";
	}
	print "All nights: $c items / \$$sum ($value)\n";
	print "Bell Ringers: $bellringers\n";
}
print "\n";

sub swrite {
	my $format = shift;
	$^A = "";
	formline($format, @_);
	return $^A;
}
