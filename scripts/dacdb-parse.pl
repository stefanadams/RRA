#!/usr/bin/perl

use HTML::TableParser;
@reqs = (
	{
		id => 1,
		row => \&row,
	},
);

my $c=0;
print "delete from rotarians;\n";
$p = new HTML::TableParser([{id=>1,row=>sub{$c++; ${$_[2]}[16] =~ /^.*?(\d{3}).*?(\d{3}).*?(\d{4}).*?$/; ${$_[2]}[16] = $1 && $2 && $3 ? "($1) $2-$3" : ''; print ${$_[2]}[10] =~ /\w/ ? "insert into rotarians (rotarian_id, lastname, firstname, phone, email) values(${$_[2]}[10], '${$_[2]}[1]', '${$_[2]}[2]', '${$_[2]}[16]', '${$_[2]}[19]');\n" : ''}}], { Decode => 1, Trim => 1, Chomp => 1 });
$p->parse_file($ARGV[0]);
print STDERR "Rotarians: $c\n";
