package RRA::API::Rotarians;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub search_POST : Runmode {
	my $self = shift;
}

sub view_POST : Runmode {
	my $self = shift;
}

sub rotarians_POST : StartRunmode { #Ajax Authen Authz('admins') {
	my $self = shift;
	my %sOper = $self->sOper;
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'rotarian', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
	$sidx = "$sidx desc, rotarian" if $sidx eq 'solicit'; # HACK for multicolumn sort
	my ($sql, @bind) = sql_interp 'SELECT count(*) FROM view_rotarians_vw WHERE', ($sField&&$sOper{$sOper}? (sql($sField).$sOper{$sOper},\$sValue) : ('1=1'));
	my $records = $self->dbh->selectrow_array($sql, {}, @bind);
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	($sql, @bind) = sql_interp 'SELECT * FROM view_rotarians_vw WHERE', ($sField&&$sOper{$sOper}? (\$sField,$sOper{$sOper},\$sValue) : ('1=1')), 'ORDER BY', sql($sidx), sql($sord), 'LIMIT', \$rows, 'OFFSET', \$start;
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
