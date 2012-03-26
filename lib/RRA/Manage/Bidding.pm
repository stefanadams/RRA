package RRA::Manage::Bidding;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub cell_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind);
	if ( grep { $_ eq $self->param('celname') } qw/phone bidder/ ) {
		($sql, @bind) = sql_interp 'UPDATE bidders JOIN bids ON bidders.bidder_id=bids.bidder_id SET', {map {$_=>$self->param($_)} $self->param('celname')}, 'WHERE', {'bids.bid_id' => $self->param('id')};
	} elsif ( $self->param('celname') eq 'bid' && !$self->param('bid') ) {
		($sql, @bind) = sql_interp 'DELETE FROM bids WHERE', {bid_id => $self->param('id')}, 'LIMIT 1';
	} else {
		($sql, @bind) = sql_interp 'UPDATE bids SET', {map {$_=>$self->param($_)} $self->param('celname')}, 'WHERE', {bid_id => $self->param('id')};
	}
	return $self->to_json({sc=>'false',msg=>"Editing disabled: $sql"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub search_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;  
}
 
sub view_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
}

sub bidding_POST : StartRunmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my %sOper = $self->sOper;
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'number', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
	my ($sql, @bind) = sql_interp 'SELECT count(*) FROM manage_bidding_vw WHERE', ($sField&&$sOper{$sOper}? (\$sField,$sOper{$sOper},\$sValue) : ('1=1'));
	my $records = $self->dbh->selectrow_array($sql, {}, @bind);
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	($sql, @bind) = sql_interp 'SELECT * FROM manage_bidding_vw WHERE', ($sField&&$sOper{$sOper}? (\$sField,$sOper{$sOper},\$sValue) : ('1=1')), 'ORDER BY', $sidx, $sord, 'LIMIT', \$rows, 'OFFSET', \$start;
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub item_POST : Runmode RequireAjax Authen Authz(':admins') {
        my $self = shift;
        my ($item_id) = ($self->param('item_id'));
        my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'number', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
        $item_id or return $self->to_json({sc=>'false',msg=>"Error: No 'id' parameter for item lookup"});
        my ($sql, @bind) = sql_interp 'SELECT count(*) FROM manage_bidding_vw_bids_sg WHERE', {item_id=>$item_id};
        my $records = $self->dbh->selectrow_array($sql, {}, @bind);
        my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
        my $start = $page * $rows - $rows || 0;
        ($sql, @bind) = sql_interp 'SELECT * from manage_bidding_vw_bids_sg WHERE', {item_id=>$item_id}, 'ORDER BY bid DESC LIMIT 20 OFFSET 0';
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
