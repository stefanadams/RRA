package RRA::Request;

use strict;
use warnings;

use CGI::Session;
use SQL::Interp ':all';
use Switch;
use base 'RRA::Base';

sub requests_POST : Runmode {
	my $self = shift;
	return $self->to_json($self->requests);
}

sub request_POST : Runmode {
	my $self = shift;
	my $request = $self->request($self->param('request'), $self->param('value'));
	return $self->to_json({request=>(defined $request?"ok":undef),request_id=>$request->{request_id}});
}

sub approve_POST : Runmode Authen Authz(':operators') {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'SELECT request_id,request,value,approve,id session_id FROM requests JOIN sessions on requests.session_id=sessions.id WHERE',{request_id=>$self->param('request_id')};
	my $request = $self->dbh->selectrow_hashref($sql, {}, @bind) or return $self->to_json({approve=>undef,msg=>'Not identified'});
	my $session = CGI::Session->new("driver:mysql", $request->{session_id}, {Handle=>$self->dbh});
	switch ( $request->{request} ) {
		case 'newbid' {
			my ($item_id, $bid) = split /:/, $request->{value};
			if ( $self->param('approve') ) {
				my $bidder_id = $session->param('bidder_id');
				unless ( $bidder_id ) {
					my $phone = $self->param('phone');
					my ($sql, @bind) = sql_interp 'SELECT bidder_id FROM bidders WHERE',{year=>2012,phone=>$self->param('phone')};
					$bidder_id = $self->dbh->selectrow_array($sql, {}, @bind) or return $self->to_json({approve=>undef,msg=>'Not identified'});
				}
				print STDERR "INSERT INTO bids (bidder_id,item_id,bid) VALUES ($bidder_id, $item_id, $bid);\n";
				my ($sql, @bind) = sql_interp 'INSERT INTO bids',{bidder_id=>$bidder_id,item_id=>$item_id,bid=>$bid};
				$self->dbh->do($sql, {}, @bind) or return $self->to_json({bid=>undef,msg=>"Error placing bid"});
			}
			my $msg = $self->param('approve')?"Bid placed!  :D":"Bid reject.  :(";
			my ($sql, @bind) = sql_interp 'INSERT INTO alerts',{alert=>$request->{session_id},msg=>$msg},'ON DUPLICATE KEY UPDATE',{msg=>$msg};
			$self->dbh->do($sql, {}, @bind) or return $self->to_json({bid=>undef,msg=>"Error placing bid"});
		}
		case 'newuser' {
			my ($username, $bidder, $phone) = split /:/, $request->{value};
			if ( $self->param('approve') ) {
				print STDERR "INSERT INTO bidders (username,phone,bidder) VALUES ($username, $phone, $bidder);\n";
				my ($sql, @bind) = sql_interp 'INSERT INTO bidders',{username=>$username,phone=>$phone,bidder=>$bidder};
				$self->dbh->do($sql, {}, @bind) or return $self->to_json({bid=>undef,msg=>"Error registering"});
			}
			my $msg = $self->param('approve')?"Registered!  :D":"Rejected.  :(";
			my ($sql, @bind) = sql_interp 'INSERT INTO alerts',{alert=>$request->{session_id},msg=>$self->param('approve')?"Registered!  :D":"Rejected.  :("},'ON DUPLICATE KEY UPDATE',{msg=>$msg};
			$self->dbh->do($sql, {}, @bind) or return $self->to_json({register=>undef,msg=>"Error registering"});
		}
	}
	my $approve = $self->approve($self->param('request_id'),$self->param('approve'));
	return $self->to_json({approve=>defined $approve?$approve?"yes":"no":undef});
}

#sub ack_POST : Runmode {
#	my $self = shift;
#	return $self->to_json($self->ack($self->param('request_id'),$self->param('ack')));
#}

1;
