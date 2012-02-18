#!/usr/bin/perl

use File::Basename;
use Date::Manip;
use DBI;

my $dir=dirname($0);
$|=1;

die "Usage: $0 {cal}[.txt]\n" unless $ARGV[0];
$ARGV[0].='.txt' unless $ARGV[0]=~/.txt$/i;
die "$ARGV[0]: not found\n" unless -f $ARGV[0];
die "$ARGV[0]: permission denied\n" unless -r $ARGV[0];
my ($dirname,$basename) = (dirname($ARGV[0]), basename($ARGV[0]));

my $table = 'items';
#my @columns_in = qw/night seq item value donor ad/;
my @columns_in = qw/seq item value donor ad/;
#my @columns_out = qw/id   name desc stat value auct donor seq bid  b-id t    t-ad ad act  night pri  phon emal/;
#my @columns_out = qw/seq item item NULL value NULL donor seq NULL NULL NULL NULL ad NULL night NULL NULL NULL/;
my @columns_out = qw/seq item item NULL value NULL donor seq NULL NULL NULL NULL ad NULL 1 NULL NULL NULL NULL NULL/;

#print "INSERT INTO $table VALUES(".(join ', ', (map { /^NULL$/ ? 'NULL' : '?' } @columns_out)).")";
#print "\n";
#print join " -=- ", grep { !/^NULL$/ } map { /^NULL$/ ? 'NULL' : $_ } @columns_out;
#print "\n";
#exit;

my $dbh_sql = DBI->connect('DBI:mysql:database=washrotary;host=mysql', 'washingtonrotary', 'harris');
my $dbh_csv = DBI->connect("DBI:CSV:f_dir=$dirname");
$dbh_csv->{'csv_tables'}->{$table} = {
	'eol' => "\n",
	'sep_char' => "\t",
	'quote_char' => undef,
	'escape_char' => undef,
	'file' => $basename,
	'skip_first_row' => 1,
	'col_names' => [@columns_in],
};
my $sth_sql = $dbh_sql->prepare("DELETE FROM $table");
$sth_sql->execute;
$sth_sql = $dbh_sql->prepare("INSERT INTO $table VALUES(".(join ', ', (map { /^NULL$/ ? 'NULL' : '?' } @columns_out)).")");
my $sth_csv = $dbh_csv->prepare("SELECT * FROM $table");
$sth_csv->execute;
my $c=0;
while (my $row = $sth_csv->fetchrow_hashref) {
	$c++;
	do { print "Skipping first row; assuming a header.\n"; next; } if $c == 1;
	next unless $row->{seq};
	foreach ( @columns_in ) {
#		$row->{$_} =~ s/'/\\'/g;
		$row->{$_} =~ s/^\s*"?\s*//;
		$row->{$_} =~ s/\s*"?\s*$//;
	}
	$row->{value} =~ s/^\$(\d+)\.(\d+)/\1/;
	$row->{night} =~ s/\s*(\d+)\s*-\s*.*/\1/;
	
#	print join " | ", grep { !/^NULL$/ } map { /^NULL$/ ? $_ : $row->{$_} } @columns_out; print "\n";
	$sth_sql->execute(grep { !/^NULL$/ } map { /^NULL$/ ? $_ : $row->{$_} } @columns_out);
}
$sth_sql = $dbh_sql->prepare("UPDATE $table SET status='Ready'");
$sth_sql->execute;
$sth_sql = $dbh_sql->prepare("SELECT COUNT(*) AS count FROM $table");
$sth_sql->execute;
$_=$sth_sql->fetchrow_hashref;
print "Processed ".$_->{count}.'/'.$c." entries from $ARGV[0]\n";
$sth_sql->finish;
$sth_csv->finish;
