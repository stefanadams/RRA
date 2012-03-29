package CGI::Application::Plugin::SiteStatus;

use warnings;
use strict;
use Carp;
use SQL::Interp ':all';
use Switch;
use base 'Exporter';
our @EXPORT = qw[sitestatus];

our $VERSION = '0.01';

sub sitestatus {
	my $self = shift;
	return 1;
}

1;
