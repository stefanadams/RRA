package RRA::API;
use base 'RRA::Base';

use Switch;
use SQL::Interp ':all';

sub resttest_GET : Runmode { # Authen Authz('auctioneer') {
	my $self = shift;
	return 'resttest_GET: '.$self->authen->username;
}
sub resttest_POST : Runmode { # Authen Authz('operators') {
	my $self = shift;
	return 'resttest_POST: '.$self->authen->username;
}
sub resttest_DELETE : Runmode { # Authen Authz('auctioneers') {
	my $self = shift;
	return 'resttest_DELETE: '.$self->authen->username;
}
sub resttest_PUT : Runmode { # Authen Authz('backend') {
	my $self = shift;
	return 'resttest_PUT: '.$self->authen->username;
}

sub bidding_GET : Runmode { # {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,highbid,startbid,minbid,bidder,bellringer,timermin timer,donor,donorurl,message FROM items_vw WHERE (status='Bidding' OR status='Sold') ORDER BY number");
}

sub ondeck_GET : Runmode { # {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,donor,donorurl,message FROM items_vw WHERE status='OnDeck' ORDER BY number");
}

sub start_GET : Runmode { # Authen Authz('admins') {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,donor,donorurl FROM items_vw WHERE status='Ready' ORDER BY seq LIMIT 10");
}

sub timer_GET : Runmode { # Authen Authz('admins') {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,highbid,startbid,minbid,bidage,bidder,auctioneer,bellringer,cansell,timermin timer,donor,donorurl,notify,auctioneer FROM items_vw WHERE status='Bidding' ORDER BY auctioneer,seq");
}

sub auction_GET : Runmode { # Authen Authz('auctioneers') {
	my $self = shift;
	return $self->to_json({
		bidding => $self->dbx("SELECT item_id id,number,itemurl,name,description,value,highbid,bidder,donor,donorurl,message,notify,timermin timer,status,bellringer FROM items_vw WHERE (status='Bidding' OR status='Sold') AND auctioneer=? ORDER BY number", undef, $api{'auctioneer'}),
		ondeck => $self->dbx("SELECT item_id id,number,itemurl,name,description,value,highbid,bidder,donor,donorurl,message,notify,timermin timer,status,bellringer FROM items_vw WHERE status='OnDeck' AND auctioneer=? ORDER BY number", undef, $api{'auctioneer'}),
	});
}

sub placebids_GET : Runmode { # Authen Authz('operators') {
	my $self = shift;
	return $self->dbx_json("SELECT item_id id,number,itemurl,name,description,value,highbid,startbid,minbid,bellringer,timermin timer FROM items_vw WHERE status='Bidding' ORDER BY number");
}

sub dev_POST : Runmode { # Authen Authz('root') {
	my $self = shift;
	$self->dbh->do("INSERT INTO auctions (year, night, start, end, live) VALUES (?, ?, now(), date_add(now(), INTERVAL ? HOUR), 0)", undef, (((localtime)[5])+1900, 1, $self->param('hours'))) if $self->param('hours');
	return $self->to_json({error=>0});
}
sub dev_DELETE : Runmode { # Authen Authz('root') {
	my $self = shift;
	$self->dbh->do("DELETE FROM auctions WHERE year=auction_year() AND live=0");
	return $self->to_json({error=>0});
}

sub alert_GET : Runmode { # {
	my $self = shift;
	my $alert = $self->param('alert') || $self->authen->username || 'public';
	return $self->to_json($self->dbh->selectrow_hashref('SELECT msg FROM alerts WHERE alert=? LIMIT 1', {Slice=>{}}, $alert));
}
sub alert_POST : Runmode { # Authen Authz('admins') {
	my $self = shift;
	my $alert = $self->param('alert') || $self->authen->username || 'public';
	my $msg = $self->query->param('msg');
	$self->dbh->do("INSERT INTO alerts (alert, msg) VALUES (?, ?) ON DUPLICATE KEY UPDATE msg=?", undef, ($alert, $msg, $msg)) if $self->authz->authorize('admins') && $alert && defined $msg;
	return $self->to_json({error=>0});
}

sub clearlastbid_DELETE : Runmode { # Authen Authz('admins') {
	my $self = shift;
	$self->dbh->do("DELETE FROM bids_vw WHERE item_id=? ORDER BY bid DESC LIMIT 1", undef, $self->param('item'));
	return $self->to_json({error=>0});
}

sub resetitem_DELETE : Runmode { # Authen Authz('admins') {
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

sub assign : Runmode { # Authen Authz('admins') {
	my $self = shift;
	$self->dbh->do("UPDATE items_vw SET auctioneer=? WHERE item_id=?", undef, ($self->param('auctioneer'), $self->param('item')));
	return $self->to_json({error=>0});
}

sub notify : Runmode { # Authen Authz('admins') {
	my $self = shift;
	$self->dbh->do("UPDATE items_vw SET notify = CONCAT_WS(',',notify,?) WHERE item_id=?", undef, $self->param('notify'), $self->param('item'));
	return $self->to_json({error=>0});
}

sub respond : Runmode { # Authen Authz('auctioneers') {
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

sub newbidder_POST : Runmode { # Authen Authz('operators') {
	my $self = shift;
	$self->dbh->do("INSERT INTO bidders (BidderID, year, Phone, Name) VALUES (null, auction_year(), ?, ?)", undef, ($self->param('phone'), $self->param('name')));
	return $self->to_json({error=>0});
}

sub bidder_id_GET : Runmode { # {
	my $self = shift;
	return $self->dbx_json("SELECT bidder_id FROM bidders WHERE username=? LIMIT 1", undef, $self->param('bidder') || $self->authen->username);
}

sub bid_POST : Runmode { # Authen Authz('operators') {
	my $self = shift;
	# Need a transaction
	$self->dbh->do("INSERT INTO bidhistory (BidNum, year, BidderID, ItemID, Amount, bhTimeStamp) VALUES (null, auction_year(), ?, ?, ?, now())", undef, ($self->param('bidder_id'), $self->param('item'), $self->param('bid')));
	$self->dbh->do("UPDATE items_vw SET notify = CONCAT_WS(',',notify,'newbid') WHERE item_id=?", undef, $self->param('item'));
	return $self->to_json({error=>0});
}

sub ad_GET : Runmode { # {
	my $self = shift;

	my $adsroot = "$ENV{ASSETS}/ads";
	print STDERR "Ads directory does not exist: $adsroot\n" unless -d $adsroot;

	return;
	# ALTER TABLE washrotary.ads ADD COLUMN rotation int and modify code to only update display count when the file exists and to rotate based on rotate and not display
	# Should update rotate every attempt for ad selection, only display when actually displayable and count when clicked
	# When an ad can't be found, instead of display the default, go on to the next (increased failed rotate but not display)
	# So, display becomes rotate and a new display is added that works like click
	my $ads = $self->dbh->selectrow_hashref("SELECT count(*) count FROM ads_vw");
	$ads = $ad->{count};
	if ( $self->param('ad_id') ) {
		my $ad = $self->dbh->selectrow_hashref("SELECT url FROM ads_vw WHERE ad_id = ?", undef, $self->param('ad_id'));
		$self->dbh->do("INSERT INTO ad_count (ad_id, year, night) VALUES (?, auction_year(), auction_night()) ON DUPLICATE KEY UPDATE click=click+1", undef, $self->param('ad_id')) if $self->param('auction') eq 'Live' && $ad->{url};
		return $self->redirect($ad->{url}||'http://www.washingtonrotary.com');
	} else {
		my $ad = {};
		foreach ( 1..$ads ) {
			$ad = $self->dbh->selectrow_hashref("SELECT ads_vw.ad_id ad_id, ads_vw.donor_id donor_id FROM ads_vw LEFT JOIN ad_count USING (ad_id) ORDER BY rotate ASC LIMIT 1") if $self->param('auction') eq 'Live';
			$ad = $self->dbh->selectrow_hashref("SELECT ads_vw.ad_id ad_id, ads_vw.donor_id donor_id FROM ads_vw LEFT JOIN ad_count USING (ad_id) ORDER BY RAND() LIMIT 1") if ref $ad ne 'HASH' || $self->param('auction') eq 'Dev'; # This should actually RAND() from ads; ad_count may be empty!
			$self->dbh->do("INSERT INTO ad_count (ad_id, year, night) VALUES (?, auction_year(), auction_night()) ON DUPLICATE KEY UPDATE rotate=rotate+1", undef, $ad->{ad_id});
			$ad->{img} = (glob("$adsroot/".$self->param('year')."/$ad->{donor_id}-$ad->{ad_id}.*"))[0] || (glob("$adsroot/".$self->param('year')."/$ad->{donor_id}.*"))[0] if $ad->{donor_id} && $ad->{ad_id};
			$ad->{url} = "api/ad/$ad->{ad_id}" if $ad->{ad_id};
			$ad->{url} && $ad->{img} && -e $ad->{img} && -f _ && -r _ and last;
		}
		if ( $ad->{url} && $ad->{img} && -e $ad->{img} && -f _ && -r _ ) {
			$self->dbh->do("INSERT INTO ad_count (ad_id, year, night) VALUES (?, auction_year(), auction_night()) ON DUPLICATE KEY UPDATE display=display+1", undef, $ad->{ad_id}) if $self->param('auction') eq 'Live' && $ad->{ad_id};
		} else {
			$ad = {img=>"$adsroot/washrotary.jpg",url=>'http://washingtonrotary.com'};
		}
		return $self->to_json({map { $_ => $ad->{$_} } qw/url img/});
	}
#	# eval { } or $@ && return a Rotary Ad / Rotary Link
#	my $ad = {};
#	if ( $self->param('auction') eq 'Live' ) {
#		$ad = $self->dbh->selectrow_hashref("SELECT ads_vw.ad_id ad_id, ads_vw.donor_id donor_id FROM ads_vw LEFT JOIN ad_count USING (ad_id) WHERE year=auction_year() AND night=auction_night() ORDER BY display ASC LIMIT 1");
#		unless ( ref $ad eq 'HASH' ) {
#			$ad = $self->dbh->selectrow_hashref("SELECT ads_vw.ad_id ad_id, ads_vw.donor_id donor_id FROM ads_vw LEFT JOIN ad_count USING (ad_id) WHERE year=auction_year() AND night=auction_night() ORDER BY RAND() LIMIT 1");
#		}
#	} elsif ( $self->param('auction') eq 'Dev' ) {
#		$ad = $self->dbh->selectrow_hashref("SELECT ads_vw.ad_id ad_id, ads_vw.donor_id donor_id FROM ads_vw LEFT JOIN ad_count USING (ad_id) WHERE year=auction_year() AND night=auction_night() ORDER BY RAND() LIMIT 1");
#	}
#	$ad->{file} = (glob("ads/".$self->param('year')."/$ad->{donor_id}-$ad->{ad_id}.*"))[0] || (glob("ads/".$self->param('year')."/$ad->{donor_id}.*"))[0] if $ad->{donor_id};
#	$self->dbh->do("INSERT INTO ad_count (ad_id, year, night) VALUES (?, auction_year(), auction_night()) ON DUPLICATE KEY UPDATE display=display+1", undef, $ad->{ad_id}) if $self->param('live') eq 'Live' && $ad->{ad_id};
#	return $ad;
}

# jqGrid colModel editoptions dataUrl dictates that the response must be HTML
sub buildselect_GET : Runmode { #Ajax Authen Authz('admins') {
	my $self = shift;
	my ($for) = split /\//, $self->param('dispatch_url_remainder');

	my $select = {};
	switch ( $for ) {
		case 'rotarians' {
			$select = $self->dbh->selectall_arrayref("SELECT rotarian_id,concat_ws(', ',lastname,firstname) name FROM rotarians ORDER BY lastname");
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

sub ac_GET : Runmode { # Ajax
	my $self = shift;
	my ($for) = split /\//, $self->param('dispatch_url_remainder');
 
	my $q = $self->param('q') || '';
	my $ac = {};
	$self->param('donor_id', $1||'') if $self->param('donor') && $self->param('donor') =~ /:(\d+)$/;
	$self->param('stockitem_id', $1||'') if $self->param('stockitem') && $self->param('stockitem') =~ /:(\d+)$/;
	my $limit = $self->param('limit') || 10;
	my ($sql, @bind);
	switch ( $for ) {
		case 'city' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_city_vw WHERE city LIKE',\"$q%",'LIMIT', \$limit;
		}
		case 'donor' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_donor_vw WHERE donor LIKE',\"$q%",'OR', {donor_id=>$q}, 'LIMIT', \$limit;
		}
		case 'item_stockitem' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_item_stockitem_vw WHERE stockitem LIKE',\"%$q%",'LIMIT', \$limit;
		}
		case 'item' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_item_vw WHERE',{number=>$q},'OR item LIKE',\"%$q%",'OR donor LIKE',\"$q%",'OR',{donor_id=>$q},'OR',{item_id=>$q},'LIMIT', \$limit;
		}
		case 'advertisement' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_advertisement_vw WHERE',{donor_id=>$q},'OR advertisement LIKE',\"%$q%",'LIMIT', \$limit;
		}
		case 'stockitem' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_stockitem_vw WHERE stockitem LIKE',\"%$q%",'LIMIT', \$limit;
		}
		case 'pay' {
			my $term = $self->query->param('term');
			my $limit = $self->query->param('limit') || 10;
			switch ( $self->param('field') ) {
				case 'number' {
					return $self->to_json({
						ac => $self->dbx("SELECT id,number,name FROM items WHERE number=? ORDER BY number LIMIT $limit", undef, $term),
					});
				}
			}
		}
		case 'bid' {
			my $term = $self->query->param('term');
			my $limit = $self->query->param('limit') || 10;
			my $ac;
			my @ac = ();
			switch ( $self->param('field') ) {
				case 'name' {
					if ( $term =~ /^\d+$/ ) {
						my ($a, $b, $c);
						if ( length($term) == 3 ) {
							$b = $term;
						} elsif ( length($term) == 4 ) {
							$c = $term
						} elsif ( length($term) > 4 && length($term) <= 7 ) {
							my ($b, $c) = ($term =~ /^(\d{3})(\d{0,4})$/);
						} elsif ( length($term) > 7 && length($term) <= 10 ) {
							my ($a, $b, $c) = ($term =~ /^(\d{3})(\d{2,3})(\d{0,4})$/);
						}
						$a .= '_' while length($a) < 3;
						$b .= '_' while length($b) < 3;
						$c .= '_' while length($c) < 4;
						$ac = $self->dbh->selectall_hashref("SELECT bidder_id id,name,phone FROM bidders_vw WHERE phone LIKE '(?) ?-?' OR phone LIKE '???' ORDER BY name LIMIT $limit", "id", undef, $a, $b, $c, $a, $b, $c);
					} else {
						$ac = $self->dbh->selectall_hashref("SELECT bidder_id id,name,phone FROM bidders_vw WHERE name LIKE ? ORDER BY name LIMIT $limit", "id", undef, "%$term%");
					}
					foreach my $id ( keys %{$ac} ) {
						push @ac, join '|', map { $_ eq 'name' ? $ac->{$id}->{$_} || '' : join ':', $_, ($ac->{$id}->{$_} || '') } qw/name phone id/;
					}
				}
			}
			return join "\n", @ac;
		}
	}
	print STDERR "\n\n\n\n\n$sql\n\n\n\n\n\n";
	$ac = $self->dbh->selectall_arrayref($sql, {}, @bind);
	return join "\n", map { @$_ } @$ac;
}

1;
