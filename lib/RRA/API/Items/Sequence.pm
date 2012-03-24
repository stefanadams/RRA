package RRA::API::Items::Sequence;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub sequence_GET : StartRunmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind);
	my $night = $self->param('dispatch_url_remainder');
	if ( defined $night ) {
		if ( $night == 9999 ) {
			($sql, @bind) = sql_interp 'SELECT concat(item," -- Night ",scheduled,", ",if(isnull(seq),"Sequence Undefined",concat("Sequence ",seq))) item FROM manage_items_sequence_vw ORDER BY number';
		} else {
			($sql, @bind) = sql_interp 'SELECT * FROM manage_items_sequence_vw WHERE', {scheduled=>$night};
		}
	} else {
		($sql, @bind) = sql_interp 'SELECT * FROM manage_items_sequence_tablabels_vw';
	}
	return $self->to_json({rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub sequence_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my $night = $self->param('dispatch_url_remainder');
	my @item_id = map { /_(\d+)$/; $1 } @{$self->param('item_id')};
	my ($sql, @bind) = sql_interp 'UPDATE items, auctions SET scheduled=cast(start AS date),seq = FIND_IN_SET(item_id, ', \join(',', @item_id), ') WHERE auctions.year=auction_year() AND', {night=>$night}, 'AND item_id IN', \@item_id;
	return $self->to_json({sc=>'false',msg=>"Sequencing Disabled"}) if $self->cfg('NOSEQ');
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
#return $self->to_json({sc=>'true',msg=>""});
	($sql, @bind) = sql_interp 'SELECT * FROM manage_items_sequence_tablabels_vw';
	return $self->to_json({sc=>'true', rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
