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

#        my $current = $self->dbh->selectrow_hashref('SELECT * FROM auctions_current_vw');
#        $self->param('year', $current->{year});
#        $self->param('night', $current->{night});
#        $self->param('live', $current->{live});
#        unless ( $current->{live} ) {
#                my $next = $self->dbh->selectrow_hashref('SELECT * FROM auctions_next_vw');
#                $self->param('year_next', $next->{year});
#                $self->param('night_next', $next->{night});
#                $self->param('date_next', $next->{date});

1;
