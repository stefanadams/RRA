package RRA::XLS;

use strict;
use warnings;

use base 'RRA::Base';
use Spreadsheet::WriteExcel;

sub postcards_GET : Runmode Authen Authz(':admins') {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'postcards.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $sql = "SELECT * FROM xls_postcards_vw";
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

sub insert_GET : Runmode Authen Authz(':admins') {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'insert.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $sql = "SELECT * FROM xls_insert_vw";
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

sub bankreport_GET : Runmode Authen Authz(':admins') {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'bankreport.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $sql = "SELECT * FROM xls_bankreport_vw";
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

sub stockreport_GET : Runmode Authen Authz(':admins') {
	my $self = shift;
	$self->header_add(
		-type => 'application/vnd.ms-excel',
		-attachment => 'stockreport.xls',
	);
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = Spreadsheet::WriteExcel->new($fh);
	my $worksheet = $workbook->add_worksheet();
	my $sql = "SELECT * FROM xls_stockreport_vw";
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
