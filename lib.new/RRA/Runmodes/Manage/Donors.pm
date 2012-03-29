package RRA::Manage::Donors;

use strict;
use warnings;

use base 'RRA::Manage';
use SQL::Interp ':all';

#        # Split contact into two contacts
#        if ( $self->query->param('contact') ) {
#                my @contacts = split /\|/, $self->query->param('contact');
#                $self->query->param('contact1', $contacts[0]) if $contacts[0];
#                $self->query->param('contact2', $contacts[1]) if $contacts[1];
#        }

sub cell_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'UPDATE donors SET', {map {$_=>$self->param($_)} $self->param('celname')}, 'WHERE', {donor_id=>$self->param('id')};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub edit_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	$self->param('url', $self->param('donorurl')||'');
	$self->param('category', $self->param('donorcat')||'');
	my ($sql, @bind) = sql_interp 'UPDATE donors SET', {map {$_=>$self->param($_)} $self->param('celname')}, 'WHERE', {donor_id=>$self->param('id')};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub add_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	$self->param('url', $self->param('donorurl')||'');
	$self->param('category', $self->param('donorcat')||'');
	my @donor = qw/donor_id chamberid phone donor category contact1 contact2 address city state zip email url advertisement solicit comments rotarian_id/;
	my ($sql, @bind) = sql_interp 'INSERT INTO donors', {map {$_=>$self->param($_)} @donor};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOADD');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub del_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'DELETE FROM donors WHERE', {donor_id=>$self->param('id')};
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

sub donors_POST : StartRunmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my %sOper = $self->sOper;
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'donor', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
	$sidx = "$sidx desc, rotarian" if $sidx eq 'solicit'; # HACK for multicolumn sort
	my ($sql, @bind) = sql_interp 'SELECT count(*) FROM manage_donors_vw WHERE', ($sField&&$sOper{$sOper}? (sql($sField).$sOper{$sOper},\$sValue) : ('1=1'));
	my $records = $self->dbh->selectrow_array($sql, {}, @bind);
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	($sql, @bind) = sql_interp 'SELECT * FROM manage_donors_vw WHERE', ($sField&&$sOper{$sOper}? (\$sField,$sOper{$sOper},\$sValue) : ('1=1')), 'ORDER BY', sql($sidx), sql($sord), 'LIMIT', \$rows, 'OFFSET', \$start;
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub donor_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($donor_id) = ($self->param('donor_id'));
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'donor', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	$donor_id or return $self->to_json({sc=>'false',msg=>"Error: No 'id' parameter for donor lookup"});
	my ($sql, @bind) = sql_interp 'SELECT count(*) FROM manage_donors_vw_items_sg WHERE', {donor_id=>$donor_id};
	my $records = $self->dbh->selectrow_array($sql, {}, @bind);
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	($sql, @bind) = sql_interp 'SELECT * from manage_donors_vw_items_sg WHERE', {donor_id=>$donor_id}, 'ORDER BY year DESC, bellringer DESC, highbid DESC LIMIT 20 OFFSET 0';
	my $sth = $self->dbh->prepare($sql);
	$sth->execute(@bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	my $i = 0;
	my $json = {};
	while ( my @row = $sth->fetchrow_array ) {
		$json->{rows}->[$i]->{id} = $row[2];
		$json->{rows}->[$i]->{cell} = [@row];
		$i++;
	}
	return $self->to_json($json);
}

sub rotariancompliance_POST : Runmode RequireAjax Authen Authz(':admins') {
        my $self = shift;
	my ($sql, @bind) = sql_interp 'INSERT INTO rotarian_compliance', {rotarian_id=>$self->param('id'), compliance=>1}, 'ON DUPLICATE KEY UPDATE compliance=IF(compliance=1,0,1)';
        return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
        $self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
        return $self->to_json({sc=>'true',msg=>""});
}

sub rotarianleader_POST : Runmode RequireAjax Authen Authz(':admins') {
        my $self = shift;
	my ($sql, @bind) = sql_interp 'UPDATE rotarians SET lead=IF(lead=1,0,1) WHERE', {rotarian_id=>$self->param('id')};
        return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
        $self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
        return $self->to_json({sc=>'true',msg=>""});
}

sub solicitationaids_GET : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my @leaders = ();
	my $rotarians = {};
	my @rotarians = ();
	my $donors = {};
	my $items = {};
	my %years = ();
	my $sthl = $self->dbh->prepare(q/SELECT * FROM solicitationaids_compliance_vw ORDER BY rotarian/);
	$sthl->execute;
	while ( my $row = $sthl->fetchrow_hashref ) {
		push @{$rotarians->{$row->{leader}}}, {
			rotarian_id => $row->{rotarian_id},
			rotarian => $row->{rotarian},
			compliance => $row->{compliance},
		} unless grep { $_->{rotarian} eq $row->{rotarian} } @{$rotarians->{$row->{leader}}};
		push @leaders, {
			leader => $row->{leader},
			rotarians => $rotarians->{$row->{leader}},
		} unless grep { $_->{leader} eq $row->{leader} } @leaders;
	}
	my $sthr = $self->dbh->prepare(q/SELECT * FROM solicitationaids_packet_vw ORDER BY rotarian,donor,year desc,bellringer desc,value desc/);
	$sthr->execute;
	while ( my $row = $sthr->fetchrow_hashref ) {
		push @{$years{$row->{donor}}}, $row->{year} if $#{$years{$row->{donor}}} <= 3;
		push @{$items->{$row->{donor}}}, {
			year => $row->{year},
			number => $row->{number},
			item => $row->{item},
			value => $row->{value},
			highbid => $row->{highbid},
			bellringer => $row->{bellringer},
			stockitem => $row->{stockitem},
		} if $row->{number} && grep { $_ == $row->{year} } @{$years{$row->{donor}}};
		push @{$donors->{$row->{rotarian}}}, {
			donor => $row->{donor},
			contact => $row->{contact},
			address => $row->{address},
			city => $row->{city},
			phone => $row->{phone},
			email => $row->{email},
			advertisement => $row->{advertisement},
			items => $items->{$row->{donor}},
		} unless grep { $_->{donor} eq $row->{donor} } @{$donors->{$row->{rotarian}}};
		push @rotarians, {
			rotarian => $row->{rotarian},
			lead => $row->{lead},
			donors => $donors->{$row->{rotarian}},
		} unless grep { $_->{rotarian} eq $row->{rotarian} } @rotarians;
	}
	return $self->to_json({leaders => [@leaders], rotarians => [@rotarians]});
}

1;
