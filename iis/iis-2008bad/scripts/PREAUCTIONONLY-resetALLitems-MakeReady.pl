#!/usr/bin/perl

use DBI;

my $dbh_sql = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
$sth_sql = $dbh_sql->prepare("DELETE FROM bidhistory");
$sth_sql->execute;
$sth_sql = $dbh_sql->prepare("ALTER TABLE bidhistory AUTO_INCREMENT=0");
$sth_sql->execute;
$sth_sql = $dbh_sql->prepare("UPDATE items SET status='Ready', auctioneer=NULL, bid=NULL, bidderid=NULL, timer=NULL, timeradmin=NULL, active=NULL, priority=NULL");
$sth_sql->execute;
$sth_sql->finish;
