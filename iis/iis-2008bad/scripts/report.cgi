#!/usr/bin/perl

# http://www.borgia.com/washrotary/scripts/report.cgi
# ./report.cgi

use warnings;
use strict;
use DBI;
use CGI;
use File::Basename;
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
my $nocgi;
{ no warnings; $nocgi = $ENV{GATEWAY_INTERFACE} !~ m!CGI!; }
if ( $nocgi ) {
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
		my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY timesold");
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
	}
	print "\n";
} elsif ( $q->param('submit') ) {
	if ( !$q->param('download') ) {
		print "Content-type: text/html\n\n";
		my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY timesold");
		$sth->execute;
		my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Night', 'Time Sold');
		print '<table><tr><th bgcolor=#777777>';
		print join '</th><th bgcolor=#777777>', @header;
		print "</th></tr>\n";
		my $c = 0;
		my $night = 0;
		my %count = ();
		my %value = ();
		my %amount = ();
		while ( my $row = $sth->fetchrow_hashref ) {
			my $bgcolor = $c%2==0?'#FFFFFF':'#EEEEEE';
			no warnings;
			my $date = UnixDate(ParseDate($row->{timesold}), '%Y-%m-%d');
			$row->{night} = $night{$date};
			my @row = map { if ( /amount/ ) { ($row->{amount}>=$row->{value}?"<font color=green>":"<font color=red>").$row->{$_}."</font>" } else { $row->{$_} } } @columns;
			$count{0}++;
			$count{$row->{night}}++;
			$value{0} += $row->{value};
			$value{$row->{night}} += $row->{value};
			$amount{0} += $row->{amount};
			$amount{$row->{night}} += $row->{amount};
			print "<tr><td bgcolor=$bgcolor>";
			print join "</td><td bgcolor=$bgcolor>", @row;
			print '</td></tr>';
			$c++;
			if ( $night && $night != $row->{night} ) {
				@_ = map { "&nbsp;" } @columns;
				$_[0] = $count{$night};
				$_[2] = $value{$night};
				$_[6] = $amount{$night};
				$_[7] = $night;
				print "<tr><td bgcolor=#AAAAAA>";
				print join "</td><td bgcolor=#AAAAAA>", @_;
				print '</td></tr>';
			}
			$night = $row->{night};
		}
		my $lastnight = ((reverse sort keys %value))[0];
		@_ = map { "&nbsp;" } @columns;
		$_[0] = $count{$night};
		$_[2] = $value{$night};
		$_[6] = $amount{$night};
		$_[7] = $night;
		print "<tr><td bgcolor=#AAAAAA>";
		print join "</td><td bgcolor=#AAAAAA>", @_;
		print '</td></tr>';
		@_ = map { "&nbsp;" } @columns;
		$_[0] = $count{0};
		$_[2] = $value{0};
		$_[6] = $amount{0};
		$_[7] = 'All';
		print "<tr><td bgcolor=#777777>";
		print join "</td><td bgcolor=#777777>", @_;
		print '</td></tr>';
		print "</table>\n";
		$sth->finish;
	} else {
		print "Content-type: application/vnd.ms-excel\n";
		print "Content-Disposition: attachment; filename=rra-".UnixDate(ParseDate("now"), '%Y')."-items.".UnixDate(ParseDate("now"), "%q").".xls\n";
		print "\n";
		my $sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY timesold");
		$sth->execute;
		my $book = Spreadsheet::WriteExcel->new("-");
		my $sheet = $book->add_worksheet();
		my $r = 0;
		my @header = ('Item ID', 'Item Description', 'Value', 'Donor Name', 'Bidder Name', 'Bidder Phone', 'Winning Bid', 'Night', 'Time Sold');
		$sheet->set_column(1, 1, 40);
		$sheet->freeze_panes(1, 0);
		$sheet->write_row($r++, 0, \@header);
		while ( my $row = $sth->fetchrow_hashref ) {
			no warnings;
			my $date = UnixDate(ParseDate($row->{timesold}), '%Y-%m-%d');
			$row->{night} = $night{$date};
			my @row = map { $row->{$_} } @columns;
			$sheet->write_row($r++, 0, \@row);
		}
		$sth->finish;
	}
} else {
	print "Content-type: text/html\n\n";
	print "<form action=\"\">\n<input type=\"checkbox\" name=\"download\" value=\"1\">Download?<br />\n";
	print "<input type=\"submit\" name=\"submit\" value=\"Generate Report\">\n</form>\n";
	print "<pre>";
	my $numericsort = $ENV{numericsort} || 0;
	my $sth = $dbh->prepare("SELECT count(id) AS total FROM items");
	$sth->execute;
	my $row = $sth->fetchrow_hashref;
	print "Total items: ",$row->{total},"\n";
	$sth = $dbh->prepare("SELECT count(id) AS remaining FROM items WHERE Status <> 'Complete'");
	$sth->execute;
	$row = $sth->fetchrow_hashref;
	print "Total items remaining: ",$row->{remaining},"\n\n";
	$sth = $dbh->prepare("SELECT * FROM ($select) AS t2 ORDER BY timesold");
	$sth->execute;
	my $report = {};
	while ( my $row = $sth->fetchrow_hashref ) {
		no warnings;
		my $date = UnixDate(ParseDate($row->{timesold}), '%Y-%m-%d');
		$row->{night} = $night{$date};
		my $key = $numericsort ? $row->{id} : "$row->{id}";
		$report->{$row->{night}}->{$key} = $row;
	}
	$sth->finish;
	my $c = 0;
	my $sum = 0;
	my $value = 0;
	my $bellringersall = 0;
	foreach my $night ( sort keys %{$report} ) {
		my $cn = 0;
		my $sumn = 0;
		my $valuen = 0;
		my $bellringers = 0;
		@_ = $numericsort ? sort { int($a) <=> int($b) } keys %{$report->{$night}} : sort keys %{$report->{$night}};
		foreach my $key ( @_ ) {
			$c++; $cn++;
			my $row = $report->{$night}->{$key};
			do { $bellringers++; $bellringersall++; } if $row->{amount} >= $row->{value};
			$sum+=$row->{amount}; $sumn+=$row->{amount};
			$value+=$row->{value}; $valuen+=$row->{value};
#			print swrite("\@>>| \@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<| \@<<<<<<<<<<<<<<<<<<| \@<<<<<<<<<| \@>
#			map { $row->{$_} } qw/id item bidder bphone amount/);
		}
		print "Night $night: $cn items / \$$sumn ($valuen)\n";
		print "Bell Ringers: $bellringers\n\n";
	}
	print "All nights: $c items / \$$sum ($value)\n";
	print "Total Bell Ringers: $bellringersall\n";
	print "</pre>";
}
