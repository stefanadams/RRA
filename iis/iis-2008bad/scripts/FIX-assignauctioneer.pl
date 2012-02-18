#!/usr/bin/perl

use DBI;

die "Usage: $0 id auctioneer(0|1)\n" unless $#ARGV == 1 && $ARGV[1] =~ /^(0|1)$/;

my $dbh_sql = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
$sth_sql = $dbh_sql->do("update items set bhTimeStamp=bhTimeStamp, auctioneer=$ARGV[1] where id=$ARGV[0] LIMIT 1;");
$sth_sql->finish;
