package RRA::Error;

use strict;
use warnings;

use base 'RRA';

sub error : ErrorRunmode Runmode {
        my $self = shift;
        if ( $self->is_ajax ) {
                return $self->to_json({error => 500, title => 'Technical Failure', msg => 'There was a technical failure: '.shift});
        } else {
                return $self->error(title => 'Technical Failure', msg => 'There was a technical failure: '.shift);
        }
}

1;
