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
my $dbh = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
if ( $0 =~ /\.pl$/ ) {
	if ( $ARGV[0] ) {
		my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 WHERE id=$ARGV[0]");
		$sth->execute;
		if ( my $row = $sth->fetchrow_hashref ) {
			no warnings;
			$row->{bphone} =~ s/^(\d{3})(\d{3})(\d{4})$/\($1\) $2-$3/;
			print "Item: $row->{id} / $row->{item}\n";
			print "Winner: $row->{bidder} / $row->{bphone}\n";
			print "Winning Bid: $row->{amount}\n";
		}
		$sth->finish;
	} else {
		my $orderby = 'id';
		my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY $orderby");
		$sth->execute;
		my $r = 0;
		my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Night', 'Time Sold');
		print join '|', $r++, @header, "\n";
		my $sum = 0;
		my $c = 0;
		while ( my $row = $sth->fetchrow_hashref ) {
			no warnings;
			my $date = UnixDate(ParseDate($row->{timesold}), '%Y-%m-%d');
			$row->{night} = $night{$date};
			my @row = map { $row->{$_} } @columns;
			print join '|', $r++, @row, "\n";
			$sum+=$row->{amount};
			$c++;
		}
		$sth->finish;
		print "Total: $c / \$$sum\n";
	}
	print "\n";
} elsif ( $q->param('submit') ) {
	if ( !$q->param('download') ) {
		my $orderby = $q->param('orderby') || 'id';
		print "Content-type: text/html\n\n";
		my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY $orderby");
		$sth->execute;
		my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Time Sold');
		print '<table><tr><th>';
		print join '</th><th>', @header;
		print "</th></tr>\n";
		while ( my $row = $sth->fetchrow_hashref ) {
			my @row = map { $row->{$_} } @columns;
			print '<tr><td>';
			print join '</td><td>', @row;
			print '</td></tr>';
		}
		print "</table>\n";
		$sth->finish;
	} elsif ( my $orderby = $q->param('orderby') || 'id' ) {
		print "Content-type: application/vnd.ms-excel\n";
		print "Content-Disposition: attachment; filename=rra-2006-items.".UnixDate(ParseDate("now"), "%q").".xls\n";
		print "\n";
		my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY $orderby");
		$sth->execute;
		my $book = Spreadsheet::WriteExcel->new("-");
		my $sheet = $book->add_worksheet();
		my $r = 0;
		my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Time Sold');
		$sheet->set_column(1, 1, 40);
		$sheet->freeze_panes(1, 0);
		$sheet->write_row($r++, 0, \@header);
		while ( my $row = $sth->fetchrow_hashref ) {
			my @row = map { $row->{$_} } @columns;
			$sheet->write_row($r++, 0, \@row);
		}
		$sth->finish;
	}
} else {
	print "Content-type: text/html\n\n";
	print "<form action=\"\">\n<input type=\"checkbox\" name=\"download\" value=\"1\">Download?<br /><select name=\"orderby\">\n<option value=\"\">Order By</option>\n";
	foreach ( @columns ) {
		print "<option value=\"$_\">$_</option>\n";
	}
	print "</select>\n<input type=\"submit\" name=\"submit\" value=\"Generate Report\">\n</form>\n";
}
