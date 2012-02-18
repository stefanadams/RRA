#!/usr/bin/perl -w

use strict;
use DBI;
use CGI;
use Date::Manip;
use Spreadsheet::WriteExcel;

my @columns = qw/id item value donor bidder bphone amount night timesold/;
my $select = "SELECT * FROM (SELECT items.id AS id, items.name AS item, items.suggestedprice AS value, items.sellername AS donor, bidders.name AS bidder, bidders.phone AS bphone, items.bid AS amount, items.night AS night, items.bhtimestamp AS timesold FROM bidhistory JOIN items ON bidhistory.itemid=items.id JOIN bidders ON bidhistory.bidderid=bidders.bidderid order by bidnum desc) AS t1 GROUP BY id";

my $q = new CGI;
my $dbh = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
if ( $0 =~ /\.pl$/ ) { my $orderby = 'id';
	my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY $orderby");
	$sth->execute;
	my $r = 0;
	my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Night', 'Time Sold');
	print join '|', $r++, @header, "\n";
	while ( my $row = $sth->fetchrow_hashref ) {
		my @row = map { $row->{$_} } @columns;
		print join '|', $r++, @row, "\n";
	}
	$sth->finish;
} elsif ( $q->param('submit') ) {
	if ( !$q->param('download') ) {
		my $orderby = $q->param('orderby') || 'timesold';
		print "Content-type: text/html\n\n";
		my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY $orderby");
		$sth->execute;
		my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Night', 'Time Sold');
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
		my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Night', 'Time Sold');
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
