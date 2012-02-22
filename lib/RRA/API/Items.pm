package RRA::API::Items;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub cell_POST : Runmode {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'UPDATE items SET', {map {$_=>$self->param($_)} $self->param('celname')}, ' WHERE item_id = ', $self->param('id');
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub edit_POST : Runmode {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'UPDATE items SET', {map {$_=>$self->param($_)} $self->param('celname')}, ' WHERE item_id = ', $self->param('id');
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub add_POST : Runmode {
	my $self = shift;
	my @item = qw/item_id year number category item description value url donor_id stockitem_id scheduled/;
	$self->param('year', sql('select auction_year()'));
	$self->param('number', sql('select NextItemNumber()'));
	my ($sql, @bind) = sql_interp 'INSERT INTO items', {map {$_=>$self->param($_)} @item};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOADD');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>"",number=>$self->param('number')});
}

sub del_POST : Runmode {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'DELETE FROM items WHERE item_id = ', $self->param('id');
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NODEL');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub search_POST : Runmode {
	my $self = shift;  
}
 
sub view_POST : Runmode {
	my $self = shift;
}

sub items_POST : StartRunmode { #Authen Authz('admins') {
	my $self = shift;
	$self->param('donor_id', $1||'') if $self->param('donor') && $self->param('donor') =~ /:(\d+)$/;
	$self->param('stockitem_id', $1||'') if $self->param('stockitem') && $self->param('stockitem') =~ /:(\d+)$/;
	my %sOper = $self->sOper;
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'number', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
	my $search = '';
	$search ||= "WHERE $sField$sOper{$sOper}" if $sField && $sOper{$sOper};
	my $records = $self->dbh->selectrow_array("SELECT count(*) FROM items $search", {}, ($sField && $sOper{$sOper} && $sValue ? $sValue : ()));
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	my ($sql, @bind) = ("SELECT item_id, year, number, category, item, description, value, itemurl, donor_id, advertisement, if(donor_id,concat_ws(':', donor,donor_id),null) donor, if(stockitem_id,concat_ws(':', item,stockitem_id),null) stockitem FROM items_cy $search ORDER BY $sidx $sord LIMIT ?,?", ($sField && $sOper{$sOper} && $sValue ? $sValue : ()), $start, $rows);
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
