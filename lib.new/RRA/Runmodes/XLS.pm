package RRA::XLS;

use strict;
use warnings;

use base 'RRA';

sub xls_GET : Runmode Authen Authz(':admins') {
	my $self = shift;
	$self->header_add(-attachment => $self->param('view').'.xls');
	open my $fh, '>', \my $str or die "Failed to open filehandle: $!";
	my $workbook = $self->writeexcel($fh);
	my $worksheet = $workbook->add_worksheet();
	my $sql = $self->sql_interp('SELECT * FROM', sql('xls_'.$self->param('view').'_vw'));
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
