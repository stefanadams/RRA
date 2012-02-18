#!/usr/bin/perl

use DBI;

die "Usage: $0 id newseq\n" unless $ARGV[0] && $ARGV[1];
my ($id, $newseq) = @ARGV;

my $dbh = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
$_ = $dbh->selectcol_arrayref("select sequencenumber from items where id=$id");
my $curseq = $_->[0];

my $old = $dbh->selectall_hashref("select id,sequencenumber from items order by sequencenumber", 'id');
if ( grep { /^$newseq$/ } map { $old->{$_}->{sequencenumber} } keys %{$old} ) {
	my $s = $newseq;
	my $new = $dbh->selectall_hashref("select id,sequencenumber from items where sequencenumber >= $newseq order by sequencenumber", 'id');
	foreach my $i ( sort { $new->{$a}->{sequencenumber} <=> $new->{$b}->{sequencenumber} } keys %{$new} ) {
		$s++;
#		print "1:update items set sequencenumber=$s where id=$i ($old->{$i}->{sequencenumber})\n";
		$dbh->do("update items set sequencenumber=$s where id=$i");
	}
}
#print "update items set sequencenumber=$newseq where id=$id\n\n";
$dbh->do("update items set sequencenumber=$newseq where id=$id");

#my $s = 0;
#$old = $dbh->selectall_hashref("select id,sequencenumber from items order by sequencenumber", 'id');
#foreach my $i ( sort { $old->{$a}->{sequencenumber} <=> $old->{$b}->{sequencenumber} } keys %{$old} ) {
#	$s++;
##	print "3:update items set sequencenumber=$s where id=$i ($old->{$i}->{sequencenumber})\n";
#	$dbh->do("update items set sequencenumber=$s where id=$i");
#}

$dbh->disconnect;
