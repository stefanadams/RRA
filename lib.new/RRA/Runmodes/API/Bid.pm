package RRA::About;

use strict;
use warnings;

use base 'RRA::Base';

sub about_GET : Runmode RequireAjax {
	my $self = shift;
	return $self->return_json($self->about->{$self->param('about')||'about'}||{});
}

1;
