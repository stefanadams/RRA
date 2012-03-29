package RRA::Logout;

use strict;
use warnings;

use base 'RRA::Base';

sub logout_GET : Runmode {
        my $self = shift; 
        return $self->forward('logout');
}
sub logout_POST : Runmode {
        my $self = shift;  
        return $self->forward('logout');
}
 
sub logout : Runmode {
        my $self = shift;
        $self->authen->logout;
        return join(
                "\n",
                CGI::start_html(-title => 'Signed Out!'),
                CGI::h2('Signed Out'),
                CGI::a({href=>'/rra/login.html'}, "Sign In"),
                CGI::end_html(),
        );
}

1;
