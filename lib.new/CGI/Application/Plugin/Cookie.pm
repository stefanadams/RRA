package CGI::Application::Plugin::Cookie;

# Stolen from CAP:AutoRunmode and CAP:RequireSSL

use warnings;
use strict;
use Carp;
use base 'Exporter';
our @EXPORT = qw[cookie];
use Apache2::Cookie;
#use CGI::Cookie;
our $VERSION = '0.01';

sub cookie {
	my $self = shift;
	my $r = $self->param('r');

	if ( $#_ == -1 ) {
		# Get
		return Apache2::Cookie::Jar->new($r);
	} elsif ( $#_ == 0 && !ref ) {
		# Get
		my $jar = Apache2::Cookie::Jar->new($r);
		return $jar->cookie($_)->value;
		#return CGI::Cookie->new();
	} else {
		# Set
		return Apache2::Cookie->new($r, @_)->bake;
		#return CGI::Cookie->new(@_);
	}
}

1;
