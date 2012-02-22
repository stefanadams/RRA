package RRA::Bookmarks;

use strict;
use warnings;

use base 'RRA::Base';

sub bookmarks_GET : Runmode {
	my $self = shift;
	return $self->to_json({rows => $self->dbh->selectall_arrayref("SELECT * FROM bookmarks", {Slice=>{}})});
}

1;
