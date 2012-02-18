#!/usr/bin/perl

use DBI;

die "Usage: $0 itemid\n" unless $ARGV[0];

my $dbh_sql = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
$sth_sql = $dbh_sql->prepare("DELETE FROM bidhistory WHERE itemid=$ARGV[0]");
$sth_sql->execute;
$sth_sql = $dbh_sql->prepare("UPDATE items SET bhTimeStamp=bhTimeStamp, status='Ready', auctioneer=NULL, bid=NULL, bidderid=NULL, timer=NULL, timeradmin=NULL, active=NULL, priority=NULL WHERE id=$ARGV[0]");
$sth_sql->execute;
$sth_sql->finish;
