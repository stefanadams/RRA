package CGI::Application::Plugin::Alert;

use warnings;
use strict;
use Carp;
use base 'Exporter';
our @EXPORT = qw[alert];

our $VERSION = '0.01';

sub alert {
	my $self = shift;
	my ($alert, $msg) = @_;
	if ( $alert && $msg ) {
		if ( $self->authz->authorize(':operators') ) {
			# INSERT INTO alerts {alert=>$alert,msg=>$msg} ON DUPLICATE KEY UPDATE {msg=>$msg}
		}
	} elsif ( $alert ) {
		if ( $self->authz->authorize(':operators') ) {
			# SELECT alert FROM alerts WHERE {alert=>$alert}
		}
	} else {
		# SELECT alert FROM alerts WHERE {alert=>$self->session->id} UNION SELECT alert FROM alerts WHERE alert IN (_expand_groups) LIMIT 1
		# DELETE FROM alerts WHERE {alert=>$self->session->id};
	}
}

1;
