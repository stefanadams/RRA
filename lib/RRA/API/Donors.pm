package RRA::API::Donors;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub cell_POST : Runmode {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'UPDATE donors SET', {map {$_=>$self->param($_)} $self->param('celname')}, ' WHERE donor_id = ', $self->param('id');
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub edit_POST : Runmode {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'UPDATE donors SET', {map {$_=>$self->param($_)} $self->param('celname')}, ' WHERE donor_id = ', $self->param('id');
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub add_POST : Runmode {
	my $self = shift;
	my @donor = qw/donor_id chamberid phone donor category contact1 contact2 address city state zip email url advertisement solicit comments rotarian_id/;
	my ($sql, @bind) = sql_interp 'INSERT INTO donors', {map {$_=>$self->param($_)} @donor};
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOADD');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
	return $self->to_json({sc=>'true',msg=>""});
}

sub del_POST : Runmode {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'DELETE FROM donors WHERE donor_id = ', $self->param('id');
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

sub donors_POST : StartRunmode { #Ajax Authen Authz('admins') {
	my $self = shift;
	my %sOper = $self->sOper;
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'donor', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
	$sidx = "$sidx desc, rotarian" if $sidx eq 'solicit'; # HACK for multicolumn sort
	my $search = $sField && $sOper && !$sValue ? 'WHERE donor="" or phone="(999) 999-9999" or address="" or city=""' : ''; # Easter Egg Advanced Search
	$search ||= "WHERE $sField$sOper{$sOper}" if $sField && $sOper{$sOper};
	my $records = $self->dbh->selectrow_array("select count(*) from (`donors` left join `rotarians` on((`donors`.`rotarian_id` = `rotarians`.`rotarian_id`))) $search", {}, ($sField && $sOper{$sOper} && $sValue ? $sValue : ()));
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	my ($sql, @bind) = ("select `donors`.`rotarian_id` AS `rotarian_id`,`donors`.`donor_id` AS `donor_id`,`donors`.`chamberid` AS `chamberid`,`donors`.`phone` AS `phone`,`donors`.`donor` AS `donor`,`donors`.`category` AS `category`,`donors`.`contact1` AS `contact1`,`donors`.`contact2` AS `contact2`,concat_ws('|',`donors`.`contact1`,`donors`.`contact2`) AS `contact`,`donors`.`address` AS `address`,`donors`.`city` AS `city`,`donors`.`state` AS `state`,`donors`.`zip` AS `zip`,`donors`.`email` AS `email`,`donors`.`url` AS `url`,`donors`.`advertisement` AS `advertisement`,`donors`.`solicit` AS `solicit`,`donors`.`comments` AS `comments`,concat_ws(', ',`rotarians`.`lastname`,`rotarians`.`firstname`) AS `rotarian`,`ItemCount`(`donors`.`donor_id`) AS `items` from (`donors` left join `rotarians` on((`donors`.`rotarian_id` = `rotarians`.`rotarian_id`))) $search group by `donors`.`donor_id` ORDER BY $sidx $sord LIMIT ?,?", ($sField && $sOper{$sOper} && $sValue ? $sValue : ()), $start, $rows);
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub items_POST : Runmode {
	my $self = shift;
	my ($donor_id, $sidx, $sord, $page, $rows) = ($self->param('id'), $self->param('sidx')||'donor', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	$donor_id or return $self->to_json({sc=>'false',msg=>"Error: No 'id' parameter for donor lookup"});
	my $records = $self->dbh->selectrow_array("SELECT COUNT(*) count FROM items WHERE donor_id=?", {}, $donor_id);
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	my ($sql, @bind) = ("select `items_vw`.`donor_id` AS `donor_id`,`items_vw`.`year` AS `year`,`date2night`(`items_vw`.`sold`) AS `sold`,`items_vw`.`number` AS `number`,`items_vw`.`item` AS `item`,`items_vw`.`value` AS `value`,`items_vw`.`highbid` AS `highbid`,if(`items_vw`.`bellringer`,'Yes','No') AS `bellringer` from `items_vw` where donor_id=? order by `items_vw`.`year` desc,if(`items_vw`.`bellringer`,'Yes','No') desc,`items_vw`.`highbid` desc limit 0,20", $donor_id);
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

sub packet_GET : Runmode {
	my $self = shift;
	my @leaders = ();
	my $rotarians = {};
	my @rotarians = ();
	my $donors = {};
	my $items = {};
	my $sthl = $self->dbh->prepare("select concat(l.lastname,', ',l.firstname) leader, concat(r.lastname,', ',r.firstname) rotarian from rotarians l join rotarians r on l.rotarian_id=r.leader_id");
	$sthl->execute;
	while ( my $row = $sthl->fetchrow_hashref ) {
		push @{$rotarians->{$row->{leader}}}, {
			rotarian => $row->{rotarian},
		} unless grep { $_->{rotarian} eq $row->{rotarian} } @{$rotarians->{$row->{leader}}};
		push @leaders, {
			leader => $row->{leader},
			rotarians => $rotarians->{$row->{leader}},
		} unless grep { $_->{leader} eq $row->{leader} } @leaders;
	}
	my $sthr = $self->dbh->prepare("select concat_ws(', ', rotarians.lastname,rotarians.firstname) rotarian,donors.donor,concat_ws(' | ',donors.contact1,donors.contact2) contact,donors.address,donors.city,donors.phone,donors.email,donors.advertisement,items.year,items.number,items.item,items.value,max(bids.bid) highbid,if(max(bids.bid)>=items.value,'(BELLRINGER)','') bellringer,if(items.stockitem_id,'(STOCKITEM)','') stockitem from rotarians left join donors using (rotarian_id) left join items using (donor_id) left join bids using (item_id) where donors.solicit=1 group by donor_id,bids.item_id order by rotarian asc, donors.donor asc, items.year desc, items.value desc");
	$sthr->execute;
	while ( my $row = $sthr->fetchrow_hashref ) {
		push @{$items->{$row->{donor}}}, {
			year => $row->{year},
			number => $row->{number},
			item => $row->{item},
			value => $row->{value},
			highbid => $row->{highbid},
			bellringer => $row->{bellringer},
			stockitem => $row->{stockitem},
		} if $row->{number};
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
			donors => $donors->{$row->{rotarian}},
		} unless grep { $_->{rotarian} eq $row->{rotarian} } @rotarians;
	}
	return $self->to_json({leaders => [@leaders], rotarians => [@rotarians]});
}

1;
