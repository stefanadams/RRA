package RRA::Template;
use base 'RRA::Base';

sub template_GET : Runmode { my $self = shift; $self->template->fill($self->param('dispatch_url_remainder'), {c=>$self}); }

1;
