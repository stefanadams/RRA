package RRA::Manage::Ads::Schedule;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub schedule_GET : StartRunmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind);
	my $n = $self->param('n');
	if ( defined $n ) {
		if ( $n eq '9999' ) {
			($sql, @bind) = sql_interp 'SELECT concat(ad," -- Night ",scheduled) ad FROM schedule_ads_vw ORDER BY number';
		} else {
			($sql, @bind) = sql_interp 'SELECT * FROM schedule_ads_vw WHERE', {night=>$n};
		}
	} else {
		($sql, @bind) = sql_interp 'SELECT * FROM schedule_ads_tablabels_vw';
	}
	return $self->to_json({rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub schedule_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my $n = $self->param('n');
	my ($sql, @bind) = sql_interp 'UPDATE ad, auctions SET scheduled=cast(start AS date) WHERE auctions.year=auction_year() AND', {night=>$n, ad_id=>$self->param('ad_id')}; 
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
#return $self->to_json({sc=>'true',msg=>""});
	($sql, @bind) = sql_interp 'SELECT * FROM schedule_ads_tablabels_vw';
	return $self->to_json({sc=>'true', rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
