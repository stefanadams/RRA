package RRA::Identify;

use strict;
use warnings;

use SQL::Interp ':all';
use Switch;
use base 'RRA::Base';

sub identify_POST : Runmode {
	my $self = shift;
	my ($username, $phone) = ($self->param('username'), $self->param('phone'));
	if ( $username && $phone ) {
	        my ($sql, @bind) = sql_interp 'SELECT bidder_id,bidder,phone FROM bidders WHERE phone LIKE ',\"%$phone",'AND',{year=>2012,username=>$username};
        	my $bidder = $self->dbh->selectrow_hashref($sql, {}, @bind) or return $self->to_json({identify=>undef,msg=>'Not identified'});
		$self->session->param(bidder_id=>$bidder->{bidder_id},bidder=>$bidder->{bidder},phone=>$bidder->{phone});
		return $self->to_json({identify=>$self->session->param('bidder_id') eq $bidder->{bidder_id}?"yes":"no"});
	} else {
		$self->session->clear([qw/bidder_id bidder phone/]);
		return $self->to_json({identify=>$self->session->param('bidder_id')?"yes":"no"});
	}
}

1;
