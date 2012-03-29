package RRA::Runmodes::Users;

use strict;
use warnings;

use base 'RRA::Runmodes';

sub register_GET : Runmode {
	my $self = shift;
	# INSERT INTO bidders {username=>$username,phone=>$phone,bidder=>$name,active=>0}
	# SELECT bidder_id FROM BIDDERS WHERE {username=>$username,phone=>$phone,bidder=>$name,active=>0}
	$self->session->param('bidder_id', $bidder_id)
}

sub activate_GET : Runmode Authen Authz(':operators') {
	my $self = shift;
	# UPDATE bidders SET active=1 WHERE {bidder_id=>$bidder_id,active=>0}
	$self->alert($bidder_id, "User activated");
}

sub reject_GET : Runmode Authen Authz(':operators') {
	my $self = shift;
	# DELETE FROM bidders WHERE {bidder_id=>$bidder_id,active=>0}
	$self->alert($bidder_id, "User rejected");
}

1;
