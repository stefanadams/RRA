package RRA::Runmodes::Bid;

use strict;
use warnings;

use base 'RRA::Runmodes';

sub request_GET : Runmode {
	my $self = shift;
	# INSERT INTO bids {bidder_id=>$self->bidder,item_id=>$item_id,bid=>bid,active=>0}
	# SELECT bid_id FROM bids WHERE {bidder_id=>$self->bidder,item_id=>$item_id,bid=>bid,active=>0}
}

sub accept_GET : Runmode Authen Authz(':operators') {
	my $self = shift;
	# UPDATE bids SET active=1 WHERE {bid_id=>$bid_id,active=>0}
	# SELECT bidder_id FROM bids WHERE {bid_id=>$bid_id,active=>1}
	$self->alert($bidder_id, "Bid accepted");
}

sub reject_GET : Runmode Authen Authz(':operators') {
	my $self = shift;
	# DELETE FROM bids WHERE {bid_id=>$bid_id,active=>0}
	$self->alert($bidder_id, "Bid rejected.");
}

1;
