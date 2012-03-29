package RRA::API::BuildSelect;
use base 'RRA';

use Switch;
use SQL::Interp ':all';

# jqGrid colModel editoptions dataUrl dictates that the response must be HTML
sub bs_GET : Runmode RequireAjax Authen Authz('admins') {
	my $self = shift;
	my @dur = split /\//, $self->param('dispatch_url_remainder');
	my ($for) = shift @dur;

	my $select = {};
	switch ( $for ) {
		case 'rotarians' {
			$select = $self->dbh->selectall_arrayref("SELECT rotarian_id,concat_ws(', ',lastname,firstname) name FROM rotarians ORDER BY lastname");
		}
		case 'bellitems' {
			my $bidder_id = $self->param('bidder_id');
			my ($sql, @bind) = sql_interp 'select * from bs_bellitem_vw where', {bidder_id=>$bidder_id};
			$select = $self->dbh->selectall_arrayref($sql, {}, @bind);
			#SELECT bellitem_id,bellitem name FROM bellitems ORDER BY bellitem");
		}
		case 'donor_id' {
			$select = $self->dbh->selectall_arrayref("SELECT donor_id,name FROM donors_vw ORDER BY name");
		}
		case 'stockitem_id' {
			$select = $self->dbh->selectall_arrayref("SELECT stockitem_id,concat(name,' (',value,')') namevalue FROM stockitems ORDER BY name");
		}
	}
	return "<select>\n<option value=\"\" />\n".join("\n", map { "<option value=\"$_->[0]\">$_->[1]</option>" } @$select)."\n</select>\n";
}

1;
