package RRA::Login;

use strict;
use warnings;

use base 'RRA::Base';

sub login_GET : Runmode {
        my $self = shift;
        return $self->forward('login');
}
sub login_POST : Runmode {
        my $self = shift; 
        return $self->forward('login');
}
 
sub login : Runmode {
        my $self = shift;
        if ( $self->authen->username ) {
                if ( $self->is_ajax ) { 
                        return $self->return_json({error => 401});
                } else {
                        return join("\n",
                                CGI::start_html(-title => 'Unauthorized'),
                                CGI::h2('Unauthorized'),
                                CGI::p('You do not have permission to perform that action'),
                                CGI::end_html(),
                        );
                }
        } else { 
                if ( $self->is_ajax ) {
                        return $self->return_json({error => 403});
                } else {
                        return $self->authen->login_box;
                }
        }
}

1;
