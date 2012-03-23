package RRA::Backup;

use strict;
use warnings;

use base 'RRA::Base';

sub backup_GET : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	$_=qx{/data/vhosts/washingtonrotary.com/dev/htdocs/rra/scripts/backup1.sh};
	return "Backing up data and applications: $_";
}

1;
