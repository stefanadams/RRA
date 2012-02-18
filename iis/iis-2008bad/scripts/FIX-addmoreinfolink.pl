#!/usr/bin/perl

use DBI;

die "Usage: $0 id {jpg,pdf,html,...}\n" unless $ARGV[0] && $ARGV[1];

my $dbh_sql = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
$sth_sql = $dbh_sql->do("update items set bhTimeStamp=bhTimeStamp, moreinfo=\"http://www.washingtonrotary.com/auction-moreinfo/$ARGV[0].$ARGV[1]\" where id=$ARGV[0] LIMIT 1");
$sth_sql->finish;

print $ARGV[1] eq 'html' ? "Create cog-ent.com:/data/vhosts/www.washingtonrotary.com/htdocs/mambo/auction-moreinfo/$ARGV[0].$ARGV[1] with these contents:\n<META HTTP-EQUIV=\"refresh\" content=\"0;URL=__INSERT_URL_HERE__\">\n" : "Upload $ARGV[0].$ARGV[1] to cog-ent.com:/data/vhosts/www.washingtonrotary.com/htdocs/mambo/auction-moreinfo\n";
