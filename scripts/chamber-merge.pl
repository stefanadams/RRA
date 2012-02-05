#!/usr/bin/perl

use strict;
use warnings;
use DBI;

die "Usage: $0 y1 y2 csv\n" unless $ARGV[0] && $ARGV[1] && $ARGV[2];

my $y1 = DBI->connect("DBI:mysql:database=washrotary_$ARGV[0];host=mysql.washingtonrotary.com", 'washingtonrotary', 'harris');
my $y2 = DBI->connect("DBI:mysql:database=washrotary_$ARGV[1];host=mysql.washingtonrotary.com", 'washingtonrotary', 'harris');
my $existing = $y1->selectall_hashref('select * from donors', 'donor_id');
$y2->do('delete from donors');
$y2->do('ALTER TABLE donors AUTO_INCREMENT = 0');
my %map = map { $existing->{$_}->{chamberid} => $_ } grep { $existing->{$_}->{chamberid} } keys %{$existing};
my @new = ();

open CSV, $ARGV[2];
CSVLOOP: while ( <CSV> ) {
	chomp;
	($_{chamberid}, $_{name}, $_{contact1}, $_{phone}, $_{address}, $_{city}, $_{state}, $_{zip}) = split /\t/, $_;
	$_{phone} =~ s/\D//g;

	if ( $map{$_{chamberid}} ) {
		next if join("\t", map { $existing->{$map{$_{chamberid}}}->{$_}||'' } qw/chamberid name contact1 phone address city state zip/) eq join("\t", map { $_{$_}||'' } qw/chamberid name contact1 phone address city state zip/);
		print "Updating existing $map{$_{chamberid}} ($_{chamberid})...\n";
		print join("\t", 'Old: ', map { $existing->{$map{$_{chamberid}}}->{$_}||'' } qw/chamberid name contact1 phone address city state zip/), "\n";
		$existing->{$map{$_{chamberid}}}->{$_} = $_{$_} foreach qw/chamberid name contact1 phone address city state zip/;
		print join("\t", 'New: ', map { $existing->{$map{$_{chamberid}}}->{$_}||'' } qw/chamberid name contact1 phone address city state zip/), "\n";
#		print join "\t", map { defined $existing->{$map{$_{chamberid}}}->{$_} ? $existing->{$map{$_{chamberid}}}->{$_} : '.' } qw/donor_id chamberid phone name category contact1 contact2 address city state zip email url advertisement solicit comments rotarian_id/;
#		print "\n";
	} else {
		print "Adding new undef ($_{chamberid})...\n";
		$_ = {
			chamberid => $_{chamberid},
			phone => $_{phone},
			name => $_{name},
			category => undef,
			contact1 => $_{contact1},
			contact2 => undef,
			address => $_{address},
			city => $_{city},
			state => $_{state},
			zip => $_{zip},
			email => undef,
			url => undef,
			advertisement => undef,
			solicit => 1,
			comments => undef,
			rotarian_id => undef,
		};
		push @new, $_;
#		print join "\t", map { defined $_ ? $_ : '.' } undef, $_->{chamberid}, $_->{phone}, $_->{name}, undef, $_->{contact1}, undef, $_->{address}, $_->{city}, $_->{state}, $_->{zip}, undef, undef, undef, 1, undef, undef;
#		print "\n";
	}
}
close CSV;

print "Adding existing records...\n";
foreach my $donor_id ( sort { $a <=> $b } keys %{$existing} ) {
	$y2->do('insert into donors (donor_id, chamberid, phone, name, category, contact1, contact2, address, city, state, zip, email, url, advertisement, solicit, comments, rotarian_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {}, map { $existing->{$donor_id}->{$_} } qw/donor_id chamberid phone name category contact1 contact2 address city state zip email url advertisement solicit comments rotarian_id/);
}
print "Adding new records...\n";
foreach ( @new ) {
	$y2->do('insert into donors (donor_id, chamberid, phone, name, category, contact1, contact2, address, city, state, zip, email, url, advertisement, solicit, comments, rotarian_id) VALUES (null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {}, $_->{chamberid}, $_->{phone}, $_->{name}, undef, $_->{contact1}, undef, $_->{address}, $_->{city}, $_->{state}, $_->{zip}, undef, undef, undef, 1, undef, undef);
}
