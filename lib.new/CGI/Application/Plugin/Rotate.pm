package CGI::Application::Plugin::Rotate;

# Stolen from CAP:AutoRunmode and CAP:RequireSSL

use warnings;
use strict;
use Carp;
use SQL::Interp ':all';
use Switch;
use base 'Exporter';
our @EXPORT = qw[rotate];

our $VERSION = '0.01';

sub rotate {
	my $self = shift;

        #return {img=>'washrotary.jpg',ad_id=>618,closed=>1} unless $self->param('live');
        my $adsroot = $self->cfg('ADS');
        return $self->session->param('AD') if $self->session->param('_AD_CTIME') && time-$self->session->param('_AD_CTIME')<=10;
        $self->session->param('_AD_CTIME', time);
        my ($sql, @bind) = sql_interp 'SELECT count(*) count FROM ads_today_vw';
        my $ads = $self->dbh->selectrow_array($sql, {}, @bind);
        my $ad = {};
        foreach ( 1..$ads ) {
                my ($sql, @bind) = sql_interp 'SELECT * FROM adcount_today_vw ORDER BY rotate ASC, RAND() LIMIT 1';
                $ad = $self->dbh->selectrow_hashref($sql, {}, @bind);
                next unless $ad->{ad_id};
                ($sql, @bind) = sql_interp 'INSERT INTO adcount', {ad_id=>$ad->{ad_id}, processed=>sql('now()')}, 'ON DUPLICATE KEY UPDATE rotate=rotate+1';
                $self->dbh->do($sql, {}, @bind);
                $ad->{img} = (glob("$adsroot/$ad->{year}/$ad->{advertiser_id}-$ad->{ad_id}.*"))[0] || (glob("$adsroot/$ad->{year}/$ad->{advertiser_id}.*"))[0] if $ad->{advertiser_id} && $ad->{ad_id};
                $ad->{img} && -e $ad->{img} && -f _ && -r _ && do {
                        $ad->{img} =~ s/^$adsroot\/?// or $ad->{img} = undef;
                        $ad->{refresh} = 1;
                        last;
                }
        } 
        if ( $ad->{img} && $ad->{ad_id} ) {
                my ($sql, @bind) = sql_interp 'INSERT INTO adcount', {ad_id=>$ad->{ad_id}, processed=>sql('now()')}, 'ON DUPLICATE KEY UPDATE display=display+1';
                $self->dbh->do($sql, {}, @bind);
        } else {
                $ad = {img=>'washrotary.jpg',ad_id=>618,error=>1};
        }

        $self->session->param('AD', {map { $_ => $ad->{$_} } qw/ad_id img error/});
        return {map { $_ => $ad->{$_} } qw/ad_id img ad_error refresh/};
}

1;
