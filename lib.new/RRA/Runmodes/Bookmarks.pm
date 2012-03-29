package RRA::Bookmarks;

use strict;
use warnings;

use base 'RRA::Base';

sub bookmarks_GET : Runmode RequireAjax Authen Authz(':operators,:auctioneers') {
	my $self = shift;
        return $self->to_json({rows => $self->dbh->selectall_arrayref(q/SELECT * FROM bookmarks ORDER BY category,linkorder/)});
}

1;
