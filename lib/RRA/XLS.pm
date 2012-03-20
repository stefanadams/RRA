package RRA::XLS;

use strict;
use warnings;

use base 'RRA::Base';
use Spreadsheet::WriteExcel;

sub postcards_GET : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'postcards.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $sql = "SELECT * FROM postcards_vw ORDER BY donor asc";
	my $sth = $self->dbh->prepare($sql);
	$sth->execute;
	my $row=0;
	while ( my @row = $sth->fetchrow_array ) {
		$worksheet->write($row++, 0, [@row]);
	}
	$workbook->close;
	close $fh;
	return $str;
}

sub insert_GET : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'insert.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $sql = "SELECT * FROM insert_vw ORDER BY scheduled,number";
	my $sth = $self->dbh->prepare($sql);
	$sth->execute;
	my $row=0;
	while ( my @row = $sth->fetchrow_array ) {
		$worksheet->write($row++, 0, [@row]);
	}
	$workbook->close;
	close $fh;
	return $str;
}

1;
