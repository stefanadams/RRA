package CGI::Application::Plugin::About;

use warnings;
use strict;
use Carp;
use SQL::Interp ':all';
use Switch;
use base 'Exporter';
our @EXPORT = qw[about];

our $VERSION = '0.01';

sub about {
	my $self = shift;
        my ($dbname) = ($self->dbh->{Name} =~ /^([^;]+)/);
        return {
                about => {
                        name => 'Washington Rotary Radio Auction',
                        version => $VERSION,
                        database => $dbname,
                        dev => $dbname =~ /_dev$/ ? 1 : 0,
                        time => join(' - ', $$, scalar localtime),
                        rm_time => tv_interval($self->param('t0'), [gettimeofday]),
                        username => $self->authen->username,
                        year => $self->param('year'),
                        night => $self->param('night'),
                        live => $self->param('live'),  
                        year_next => $self->param('year_next') || undef,
                        night_next => $self->param('night_next') || undef,
                        date_next => $self->param('date_next') || undef,  
                },
                header => {
                        play => $self->cfg('PLAY'),
                },
        };
}
 
1;
