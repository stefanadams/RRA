package RRA::Backup;

use strict;
use warnings;

use base 'RRA::Base';
use MySQL::Backup;

sub backup_GET : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my $mb = new_from_DBH MySQL::Backup($self->dbh);
	my $backup = $self->cfg('BACKUPS').join('.', ((localtime)[5,4,3,1,2,3]), 'sql');
	open BACKUP, '>'.$self->cfg('BACKUPS').join('.', ((localtime)[5,4,3,1,2,3]), 'sql');
	print BACKUP $mb->create_structure;
	print BACKUP $mb->data_backup;
	close BACKUP;
	return "Successfully backed up!";
}

1;
