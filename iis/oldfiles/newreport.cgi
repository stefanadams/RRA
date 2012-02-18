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
my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Time Sold');
my @columns = qw/id item value donor bidder bphone amount timesold/;
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
$sth->finish;

if ( $q->param('submit') ) {
	if ( !$q->param('download') ) {
		print "Content-type: text/html\n\n";
		my $c = 0;
		my $sum = 0;
		foreach my $night ( keys %{$report} ) {
			print '<table><tr><th>';
			print join '</th><th>', @header;
			print "</th></tr>\n";
			print "<tr><td colspan=3>Night: $night</td></tr>\n";
			my $cn = 0;
			my $sumn = 0;
			@_ = $numericsort ? sort { int($a) <=> int($b) } keys %{$report->{$night}} : sort keys %{$report->{$night}};
			foreach my $key ( @_ ) {
				$c++; $cn++;
				my $row = $report->{$night}->{$key};
				$sum+=$row->{amount}; $sumn+=$row->{amount};
				print swrite("\@>>| \@<<<<<<<<<<<<<<<<<<<<| \@<<<<<<<<<<<<<<<<<<| \@<<<<<<<<<| \@>>>\n",
				 map { $row->{$_} } qw/id item bidder bphone amount/);
			}
			print "Night $night: $cn items / \$$sumn\n";
		}
		print "All nights: $c items / \$$sum\n";
	}
}
print "\n";

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

sub swrite {
	my $format = shift;
	$^A = "";
	formline($format, @_);
	return $^A;
}
