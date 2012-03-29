package RRA::Manage::Winners;

use strict;
use warnings;

use base 'RRA::Manage';
use SQL::Interp ':all';

sub cell_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind);
        if ( grep { $_ eq $self->param('celname') } qw/sold/ ) {
		if ( !$self->param('sold') ) {
	                ($sql, @bind) = sql_interp 'UPDATE items SET sold=null,cleared=null WHERE', {item_id => $self->param('id')};
		}
		return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
		$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
		return $self->to_json({sc=>'true',msg=>""});
        } elsif ( grep { $_ eq $self->param('celname') } qw/contacted/ ) {
		if ( $self->param('contacted') ) {
	                ($sql, @bind) = sql_interp 'UPDATE items SET contacted=now() WHERE', {item_id => $self->param('id')};
		} else {
	                ($sql, @bind) = sql_interp 'UPDATE items SET contacted=null WHERE', {item_id => $self->param('id')};
		}
		return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
		$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
		return $self->to_json({sc=>'true',msg=>""});
        } elsif ( grep { $_ eq $self->param('celname') } qw/bellitem_id/ ) {
		return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
                ($sql, @bind) = sql_interp 'UPDATE items SET',{bellitem_id=>$self->param('bellitem_id')},'WHERE', {item_id => $self->param('id')};
		$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
		($sql, @bind) = sql_interp 'SELECT highbidder_id FROM manage_winners_vw WHERE', {item_id => $self->param('id')};
		my ($highbidder_id) = $self->dbh->selectrow_array($sql, {}, @bind);
                ($sql, @bind) = sql_interp 'INSERT INTO bellcount', {bidder_id=>$highbidder_id, bellitem_id=>$self->param('bellitem_id')}, 'ON DUPLICATE KEY UPDATE qty=qty+1';
		$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
		return $self->to_json({sc=>'true',msg=>""});
        }
}

sub edit_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my @winners = qw/item value cost/;
	my ($sql, @bind) = sql_interp 'UPDATE winners SET', {map {$_=>$self->param($_)} @winners}, 'WHERE', {item_id => $self->param('id')};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub add_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	$self->param('category', $self->param('itemcat')||'');
	my @winners = qw/category item value cost/;
	my ($sql, @bind) = sql_interp 'INSERT INTO winners', {map {$_=>$self->param($_)} @winners};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOADD');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub del_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'DELETE FROM winners WHERE', {item_id => $self->param('id')};
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

sub winners_POST : StartRunmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my %sOper = $self->sOper;
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'number', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
	my ($sql, @bind) = sql_interp 'SELECT count(*) FROM manage_winners_vw WHERE', ($sField&&$sOper{$sOper}? (\$sField,$sOper{$sOper},\$sValue) : ('1=1'));
	my $records = $self->dbh->selectrow_array($sql, {}, @bind);
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	($sql, @bind) = sql_interp 'SELECT * FROM manage_winners_vw WHERE', ($sField&&$sOper{$sOper}? (\$sField,$sOper{$sOper},\$sValue) : ('1=1')), 'ORDER BY', $sidx, $sord, 'LIMIT', \$rows, 'OFFSET', \$start;
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
