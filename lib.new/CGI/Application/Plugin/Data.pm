package CGI::Application::Plugin::Data;

use warnings;
use strict;
use Carp;
use SQL::Interp ':all';
use Switch;
use base 'Exporter';
our @EXPORT = qw[data];

our $VERSION = '0.01';

sub data {
	my $self = shift;

	# Build param() with all of the data sent from the browser
	my $DATA = {};

	# Get POST Data
	if ( $self->query->request_method eq 'POST' ) {
		if ( !$self->query->content_type || $self->query->content_type =~ m!^application/x-www-form-urlencoded! || $self->query->content_type =~ m!multipart/form-data! ) {
			$DATA = { map { $_ => $self->query->param($_) } $self->query->param };
		} elsif ( $self->query->content_type =~ m!^application/json! ) {
			# Get JSON POST Data
			$DATA = $self->from_json($self->query->param('POSTDATA')) if $self->query->param('POSTDATA');
		}
	# Get GET Data
	} elsif ( $self->query->request_method eq 'GET' ) {
		$DATA = { map { $_ => $self->query->param($_) } $self->query->param };
	}

	# Get Dispatch Data
	$DATA->{$_} = $self->param($_) foreach $self->param('__PATH_INFO_KEYS');

	if ( $self->param('dispatch_url_remainder') ) {
		$DATA->{dispatch_url_remainder} = $self->param('dispatch_url_remainder');
		$DATA->{dispatch_url_remainder_ref} = [split m!/!, $self->param('dispatch_url_remainder')];
	}

	#$DATA->{app} = 
	$DATA->{rm} = $self->current_runmode;

	return $DATA;
}

1;
