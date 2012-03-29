package RRA::API;
use base 'RRA::Base';

use Switch;
use SQL::Interp ':all';

sub summary_POST : Runmode RequireAjax {
	my $self = shift;
	my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'number', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
	my ($sql, @bind) = sql_interp 'SELECT count(*) FROM summary_vw';
	my $records = $self->dbh->selectrow_array($sql, {}, @bind);
	my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
	my $start = $page * $rows - $rows || 0;
	($sql, @bind) = sql_interp 'SELECT * FROM summary_vw LIMIT', \$rows, 'OFFSET', \$start;
	return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub bidding_GET : Runmode RequireAjax {
	my $self = shift;
	#return $self->to_json({closed=>1}) unless $self->param('live');
	($sql, @bind) = sql_interp 'SELECT item_id,item_id id,number,itemurl,item,description,auctioneer,value,highbid,startbid,minbid,highbidder,bellringer,timerminutes timer,donor,donorurl,advertisement,advertisement message FROM items_current_vw WHERE (status="Bidding" OR status="Sold") ORDER BY number';
	return $self->return_json({bidding => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub ondeck_GET : Runmode RequireAjax {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,donor,donorurl,message FROM items_vw WHERE status='OnDeck' ORDER BY number");
}

sub start_GET : Runmode RequireAjax Authen Authz('admins') {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,donor,donorurl FROM items_vw WHERE status='Ready' ORDER BY seq LIMIT 10");
}

sub timer_GET : Runmode RequireAjax Authen Authz('admins') {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,highbid,startbid,minbid,bidage,bidder,auctioneer,bellringer,cansell,timermin timer,donor,donorurl,notify,auctioneer FROM items_vw WHERE status='Bidding' ORDER BY auctioneer,seq");
}

sub auction_GET : Runmode RequireAjax Authen Authz('auctioneers') {
	my $self = shift;
	return $self->to_json({
		bidding => $self->dbx("SELECT item_id id,number,itemurl,name,description,value,highbid,bidder,donor,donorurl,message,notify,timermin timer,status,bellringer FROM items_vw WHERE (status='Bidding' OR status='Sold') AND auctioneer=? ORDER BY number", undef, $api{'auctioneer'}),
		ondeck => $self->dbx("SELECT item_id id,number,itemurl,name,description,value,highbid,bidder,donor,donorurl,message,notify,timermin timer,status,bellringer FROM items_vw WHERE status='OnDeck' AND auctioneer=? ORDER BY number", undef, $api{'auctioneer'}),
	});
}

sub placebids_GET : Runmode RequireAjax Authen Authz('operators') {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,highbid,startbid,minbid,bellringer,timermin timer FROM items_vw WHERE status='Bidding' ORDER BY number");
}

sub clearlastbid_DELETE : Runmode RequireAjax Authen Authz('admins') {
	my $self = shift;
	$self->dbh->do("DELETE FROM bids_vw WHERE item_id=? ORDER BY bid DESC LIMIT 1", undef, $self->param('item'));
	return $self->to_json({error=>0});
}

sub resetitem_DELETE : Runmode RequireAjax Authen Authz('admins') {
	my $self = shift;
	if ( $self->param('item') eq 'all' ) {
		# Need a transaction
		$self->dbh->do("UPDATE items_vw SET auctioneer=null,start=null,timer=null,sold=null,cleared=null,called=null");
		$self->dbh->do("DELETE FROM bids_vw");
		$self->dbh->do("DELETE FROM bidders_vw");
		$self->dbh->do("DELETE FROM bellringers_vw");
		$self->dbh->do("DELETE FROM ad_count_vw");
	} else {
		# Need a transaction
		$self->dbh->do("UPDATE items_vw SET auctioneer=null,start=null,timer=null,sold=null,cleared=null,called=null WHERE item_id=?", undef, $self->param('item'));
		$self->dbh->do("DELETE FROM bids_vw WHERE item_id=?", undef, $self->param('item'));
	}
	return $self->to_json({error=>0});
}

sub assign : Runmode RequireAjax Authen Authz('admins') {
	my $self = shift;
	$self->dbh->do("UPDATE items_vw SET auctioneer=? WHERE item_id=?", undef, ($self->param('auctioneer'), $self->param('item')));
	return $self->to_json({error=>0});
}

sub notify : Runmode RequireAjax Authen Authz('admins') {
	my $self = shift;
	$self->dbh->do("UPDATE items_vw SET notify = CONCAT_WS(',',notify,?) WHERE item_id=?", undef, $self->param('notify'), $self->param('item'));
	return $self->to_json({error=>0});
}

sub respond : Runmode RequireAjax Authen Authz('auctioneers') {
	my $self = shift;
	if ( $self->param('respond') eq 'start' ) {
		$self->dbh->do("UPDATE items_vw SET started=now() WHERE item_id=?", undef, $self->param('item'));
	} elsif ( $self->param('respond') eq 'newbid' ) {
		$self->dbh->do("UPDATE items_vw SET notify=REPLACE(notify,'newbid','') WHERE item_id=?", undef, $self->param('item'));
	} elsif ( $self->param('respond') eq 'starttimer' ) {
		$self->dbh->do("UPDATE items_vw SET timer=now(),notify=REPLACE(notify,'starttimer','') WHERE item_id=?", undef, $self->param('item'));
	} elsif ( $self->param('respond') eq 'stoptimer' ) {
		$self->dbh->do("UPDATE items_vw SET timer=null,notify=REPLACE(notify,'stoptimer,'') WHERE item_id=?", undef, $self->param('item'));
	} elsif ( $self->param('respond') eq 'holdover' ) {
		$self->dbh->do("UPDATE items_vw SET notify=REPLACE(notify,'holdover','') WHERE item_id=?", undef, $self->param('item'));
	} elsif ( $self->param('respond') eq 'sell' ) {
		my $item = $self->dbh->selectrow_hashref("SELECT sold FROM items WHERE id=?", undef, $self->param('item'));
		$self->dbh->do("UPDATE items_vw SET ".(!$item->{sold}?'sold':'cleared')."=now(),notify=REPLACE(notify,'sell','') WHERE item_id=?", undef, $self->param('item'));
	}
	return $self->to_json({error=>0});
}

sub newbidder_POST : Runmode RequireAjax Authen Authz('operators') {
	my $self = shift;
	$self->dbh->do("INSERT INTO bidders (BidderID, year, Phone, Name) VALUES (null, auction_year(), ?, ?)", undef, ($self->param('phone'), $self->param('name')));
	return $self->to_json({error=>0});
}

sub bidder_id_GET : Runmode RequireAjax {
	my $self = shift;
	return $self->dbx_json("SELECT bidder_id FROM bidders WHERE username=? LIMIT 1", undef, $self->param('bidder') || $self->authen->username);
}

sub bid_POST : Runmode RequireAjax Authen Authz('operators') {
	my $self = shift;
	# Need a transaction
	$self->dbh->do("INSERT INTO bidhistory (BidNum, year, BidderID, ItemID, Amount, bhTimeStamp) VALUES (null, auction_year(), ?, ?, ?, now())", undef, ($self->param('bidder_id'), $self->param('item'), $self->param('bid')));
	$self->dbh->do("UPDATE items_vw SET notify = CONCAT_WS(',',notify,'newbid') WHERE item_id=?", undef, $self->param('item'));
	return $self->to_json({error=>0});
}

sub alert_GET : Runmode RequireAjax {
	my $self = shift;
	my $alert = $self->param('alert') || $self->session->id || $self->authen->username || 'public';
	return $self->to_json($self->dbh->selectrow_hashref('SELECT msg FROM alerts WHERE alert=? LIMIT 1', {Slice=>{}}, $alert));
}
sub alert_DELETE : Runmode RequireAjax {
	my $self = shift;
	my $alert = $self->session->id;
	$self->dbh->do('DELETE FROM alerts WHERE alert=? LIMIT 1', undef, $alert) or return $self->to_json({clearalert=>undef});
	return $self->to_json({clearalert=>1})
}
sub alert_POST : Runmode RequireAjax Authen Authz('admins') {
	my $self = shift;
	my $alert = $self->param('alert') || $self->authen->username || 'public';
	my $msg = $self->param('msg');
	$self->dbh->do("INSERT INTO alerts (alert, msg) VALUES (?, ?) ON DUPLICATE KEY UPDATE msg=?", undef, ($alert, $msg, $msg)) if $alert && defined $msg;
	return $self->to_json({alert=>$alert,msg=>$msg});
}

sub ad_GET : Runmode {
	my $self = shift;

	my $adsroot = $self->cfg('ADS');

	my ($sql, @bind) = sql_interp 'SELECT count(*) count FROM ads_today_vw';
	my $ads = $self->dbh->selectrow_array($sql, {}, @bind);
	my ($sql, @bind) = sql_interp 'SELECT adurl FROM ads_today_vw WHERE', {ad_id=>$self->param('ad_id')};
	my $url = '';
	if ( $url = $self->dbh->selectrow_array($sql, {}, @bind) ) {
		($sql, @bind) = sql_interp 'INSERT INTO adcount', {ad_id=>$self->param('ad_id'), processed=>sql('now()')}, 'ON DUPLICATE KEY UPDATE click=click+1';
		$self->dbh->do($sql, {}, @bind);
	}
	return $self->redirect($url||'http://www.washingtonrotary.com');
}

sub header_GET : Runmode RequireAjax {
	my $self = shift;
	my $out;

        my ($dbname) = ($self->dbh->{Name} =~ /^([^;]+)/);
	$out->{about} = {
		name => 'Washington Rotary Radio Auction',
		version => $RRA::Base::VERSION,
		database => $dbname,
		dev => ($dbname =~ /_dev$/ ? 1 : 0),
		time => join(' - ', $$, scalar localtime),
		#rm_time => tv_interval($self->param('t0'), [gettimeofday]),
		username => $self->authen->username,
		year => $self->param('year'),
		night => $self->param('night'),
		live => $self->param('live'),
		year_next => $self->param('year_next') || undef,
		night_next => $self->param('night_next') || undef,
		date_next => $self->param('date_next') || undef,
		bidder => $self->session->param('bidder') || undef,
	};

	$out->{header} = {
		play => $self->cfg('PLAY'),
		alert => $self->dbh->selectrow_hashref('SELECT msg FROM alerts WHERE alert=? LIMIT 1', {Slice=>{}}, $self->session->param('alert') || $self->session->id || $self->authen->username || 'public'),
	};

	$out->{ads} = {
		ad => $self->ad,
	};

	return $self->to_json($out);
}

######

sub ad {
	my $self = shift;
	#return {img=>'washrotary.jpg',ad_id=>618,closed=>1} unless $self->param('live');
	my $adsroot = $self->cfg('ADS');
	return $self->session->param('AD') if $self->session->param('_AD_CTIME') && time-$self->session->param('_AD_CTIME')<=10;
	$self->session->param('_AD_CTIME', time);
	my ($sql, @bind) = sql_interp 'SELECT count(*) count FROM ads_today_vw';
	my $ads = $self->dbh->selectrow_array($sql, {}, @bind);
	my $ad = {};
	foreach ( 1..$ads ) {
		my ($sql, @bind) = sql_interp 'SELECT * FROM adcount_today_vw ORDER BY rotate ASC, RAND() LIMIT 1';
		$ad = $self->dbh->selectrow_hashref($sql, {}, @bind);
		next unless $ad->{ad_id};
		($sql, @bind) = sql_interp 'INSERT INTO adcount', {ad_id=>$ad->{ad_id}, processed=>sql('now()')}, 'ON DUPLICATE KEY UPDATE rotate=rotate+1';
		$self->dbh->do($sql, {}, @bind);
		$ad->{img} = (glob("$adsroot/$ad->{year}/$ad->{advertiser_id}-$ad->{ad_id}.*"))[0] || (glob("$adsroot/$ad->{year}/$ad->{advertiser_id}.*"))[0] if $ad->{advertiser_id} && $ad->{ad_id};
		$ad->{img} && -e $ad->{img} && -f _ && -r _ && do {
			$ad->{img} =~ s/^$adsroot\/?// or $ad->{img} = undef;
			$ad->{refresh} = 1;
			last;
		}
	}
	if ( $ad->{img} && $ad->{ad_id} ) {
		my ($sql, @bind) = sql_interp 'INSERT INTO adcount', {ad_id=>$ad->{ad_id}, processed=>sql('now()')}, 'ON DUPLICATE KEY UPDATE display=display+1';
		$self->dbh->do($sql, {}, @bind);
	} else {
		$ad = {img=>'washrotary.jpg',ad_id=>618,error=>1};
	}

	$self->session->param('AD', {map { $_ => $ad->{$_} } qw/ad_id img error/});
	return {map { $_ => $ad->{$_} } qw/ad_id img ad_error refresh/};
}

sub return_json {
	my $self = shift;
	my $in = shift;
	my $out;
	if ( $in->{bidding} ) {
		my @bidding;
		foreach my $row ( @{$in->{bidding}} ) {
			# if((find_in_set('newbid',`items`.`notify`) > 0),1,NULL) `newbid`
			# if((`items`.`status` = 'Sold'),1,NULL) `sold`
			$row->{img} = (glob($self->cfg('PHOTOS')."2012/$row->{number}.*"))[0] if $row->{number};
			if ( $self->cfg('FAKEBIDDING') ) {
				my @notify = ();
				if ( int(rand(99)) < 25 ) {
					$row->{status} = 'Ready';
				} elsif ( int(rand(99)) < 25 ) { 
					$row->{status} = 'OnDeck';
					$row->{auctioneer} = int(rand(99)) < 50 ? 'a' : 'b';
				} elsif ( int(rand(99)) < 25 ) {
					$row->{status} = 'Bidding';
					push @notify, 'newbid' if int(rand(99)) < 20;
					if ( int(rand(99)) < 25 ) {
						push @notify, 'starttimer';
					} elsif ( int(rand(99)) < 25 ) {   
						push @notify, 'sell';      
					}
					$row->{auctioneer} = int(rand(99)) < 50 ? 'a' : 'b';
					$row->{highbid} = $row->{highbid} =~ /\d/ ? $row->{highbid} : $row->{value} - 10 + int(rand(15));
					$row->{bellringer} = $row->{highbid} >= $row->{value}; 
					$row->{highbidder} = $row->{donor};
					$row->{timer} = int(rand(99)) < 20 ? 1 : 0;
				} elsif ( int(rand(99)) < 25 ) {
					$row->{status} = 'Sold';
				} elsif ( int(rand(99)) < 25 ) {
					$row->{status} = 'Complete';
				}
				$row->{description} ||= int(rand(99)) < 20 ? 'Fuller description' : undef;
				$row->{itemurl} ||= int(rand(99)) < 20 ? 'http://google.com' : undef;
				$row->{donorurl} ||= int(rand(99)) < 20 ? 'http://google.com' : undef;
				$row->{img} ||= int(rand(99)) < 20 ? 'http://dev.washingtonrotary.com/rra/img/right_arrow_button.gif' : undef;
				$row->{notify} = join ',', @notify;
			}
			$row->{notify} = {map { $_ => 1 } split /,/, $row->{notify}};
			push @bidding, {map { $_ => $row->{$_}||'' } keys %$row};
		}
		$out->{bidding} = {
			count=>$#bidding+1,
			rows=>[@bidding]
		}
	}

        $self->header_add(
                -type => 'application/json',
        );
	return $self->to_json($out);
}

1;
