package RRA::Bidder;

use warnings;
use strict;
use Carp;
use base 'Exporter';
our @EXPORT = qw[bidder];

our $VERSION = '0.01';

# my $bidder = $self->bidder;
# print STDERR "Bidder: ", $bidder, $bidder->phone, "\n";

sub bidder { # new
	my $self = shift;
	my $class = __PACKAGE;

	if ( my $bidder = $self->{__RRA_BIDDER} ) {
		return $bidder;

		# Stringify
		return $bidder->bidder;
	} else {
		my ($bidder_id,$username,$phone);
		$self->{__RRA_BIDDER} = {};
		if ( $self->authz->authorize(':operators') ) {
			if ( ($username = $self->param('username') && $phone = $self->param('phone')) or ($username = $self->cookie('username') && $phone = $self->cookie('phone')) ) {
				# SELECT * from bidders WHERE username=>$username,phone=>$phone
			} elsif ( $bidder_id = $self->session->param('bidder_id') ) {
				# SELECT * from bidders WHERE bidder_id=>$bidder_id
			}
		} elsif ( $username = $self->session->param('bidder_id') ) {
			# SELECT * from bidders WHERE bidder_id=>$bidder_id
		} elsif ( $username = $self->authen->username ) {
			# SELECT * from bidders WHERE username=>$username
		}
		$self->session->param('bidder_id', $self->{__RRA_BIDDER}->{bidder_id});

		my $me = {bidder=>$bidder}
		return bless $self->{__RRA_BIDDER}, $class;
	}
}

sub username {
	my $self = shift;
	return $self->{username};
}

sub phone {
	my $self = shift;
	return $self->{phone};
}

# Alias name to bidder
sub bidder {
	my $self = shift;
	return $self->{bidder};
}

sub id {
	my $self = shift;
	return $self->{bidder_id};
}

1;
