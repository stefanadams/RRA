#!/usr/bin/perl

use DBI;

my $dbh_sql = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
$sth_sql = $dbh_sql->prepare("DELETE FROM bidders");
$sth_sql->execute;
$sth_sql = $dbh_sql->prepare("ALTER TABLE bidders AUTO_INCREMENT=0");
$sth_sql->execute;
$sth_sql = $dbh_sql->prepare("UPDATE items SET bidderid=NULL");
$sth_sql->execute;
$sth_sql->finish;
