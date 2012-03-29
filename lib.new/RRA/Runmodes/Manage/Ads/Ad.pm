package RRA::Manage::Ads::Ad;

use strict;
use warnings;

use base 'RRA::Manage::Ads';
use SQL::Interp ':all';

sub ad_GET : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;

	my $adsroot = $self->cfg('ADS');
	print STDERR "Ads directory not defined\n" unless defined $adsroot && $adsroot;
	print STDERR "Ads directory does not exist: $adsroot\n" unless -d $adsroot;

	# ALTER TABLE washrotary.ads ADD COLUMN rotation int and modify code to only update display count when the file exists and to rotate based on rotate and not display
	# Should update rotate every attempt for ad selection, only display when actually displayable and count when clicked
	# When an ad can't be found, instead of display the default, go on to the next (increased failed rotate but not display)
	# So, display becomes rotate and a new display is added that works like click

	my ($sql, @bind) = sql_interp 'SELECT count(*) count FROM ads_today_vw';
	my $ads = $self->dbh->selectrow_array($sql, {}, @bind);
	if ( $self->param('ad_id') ) {
		my ($sql, @bind) = sql_interp 'SELECT adurl FROM ads_today_vw WHERE', {ad_id=>$self->param('ad_id')};
		my $url = '';
		if ( $url = $self->dbh->selectrow_array($sql, {}, @bind) ) {
			($sql, @bind) = sql_interp 'INSERT INTO adcount', {ad_id=>$self->param('ad_id'), processed=>sql('now()')}, 'ON DUPLICATE KEY UPDATE click=click+1';
			$self->dbh->do($sql, {}, @bind);
		}
		return $self->redirect($url||'http://www.washingtonrotary.com');
	} else {
		my $ad = {};
		foreach ( 1..$ads ) {
			my ($sql, @bind) = sql_interp 'SELECT * FROM adcount_vw ORDER BY rotate ASC, RAND() LIMIT 1';
			$ad = $self->dbh->selectrow_hashref($sql, {}, @bind);
			($sql, @bind) = sql_interp 'INSERT INTO adcount', {ad_id=>$ad->{ad_id}, processed=>sql('now()')}, 'ON DUPLICATE KEY UPDATE rotate=rotate+1';
			$self->dbh->do($sql, {}, @bind);
			$ad->{img} = (glob("$adsroot/$ad->{year}/$ad->{advertiser_id}-$ad->{ad_id}.*"))[0] || (glob("$adsroot/$ad->{year}/$ad->{advertiser_id}.*"))[0] if $ad->{advertiser_id} && $ad->{ad_id};
			$ad->{img} && -e $ad->{img} && -f _ && -r _ && do {
				$ad->{img} =~ s/^$adsroot// or $ad->{img} = undef;
				last;
			}
		}
		if ( $ad->{img} && $ad->{ad_id} ) {
			my ($sql, @bind) = sql_interp 'INSERT INTO adcount', {ad_id=>$ad->{ad_id}, processed=>sql('now()')}, 'ON DUPLICATE KEY UPDATE display=display+1';
			$self->dbh->do($sql, {}, @bind);
		} else {
			$ad = {img=>'washrotary.jpg',ad_id=>618};
		}
		return $self->to_json({map { $_ => $ad->{$_} } qw/ad_id img/});
	}
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

1;
