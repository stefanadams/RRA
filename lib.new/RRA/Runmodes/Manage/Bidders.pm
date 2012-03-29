package RRA::Manage::Bidders;

use strict;
use warnings;

use base 'RRA::Manage';
use SQL::Interp ':all';

sub cell_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'UPDATE bidders SET', {map {$_=>$self->param($_)} $self->param('celname')}, 'WHERE', {bidder_id=>$self->param('id')};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub edit_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'UPDATE bidders SET', {map {$_=>$self->param($_)} $self->param('celname')}, 'WHERE', {bidder_id=>$self->param('id')};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub add_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my @bidder = qw/bidder_id phone bidder address city state zip email/;
	my ($sql, @bind) = sql_interp 'INSERT INTO bidders', {map {$_=>$self->param($_)} @bidder};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOADD');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub del_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'DELETE FROM bidders WHERE', {bidder_id=>$self->param('id')};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NODEL');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub search_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
}

sub view_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
}

sub bidders_POST : StartRunmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my %sOper = $self->sOper;
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'bidder', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
	$sidx = "$sidx desc, rotarian" if $sidx eq 'solicit'; # HACK for multicolumn sort
	my ($sql, @bind) = sql_interp 'SELECT count(*) FROM manage_bidders_vw WHERE', ($sField&&$sOper{$sOper}? (sql($sField).$sOper{$sOper},\$sValue) : ('1=1'));
	my $records = $self->dbh->selectrow_array($sql, {}, @bind);
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	($sql, @bind) = sql_interp 'SELECT * FROM manage_bidders_vw WHERE', ($sField&&$sOper{$sOper}? (\$sField,$sOper{$sOper},\$sValue) : ('1=1')), 'ORDER BY', sql($sidx), sql($sord), 'LIMIT', \$rows, 'OFFSET', \$start;
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
