package RRA::API::RotarianLeaders;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub leaders_POST : Runmode {
        my $self = shift;
	my $sql = q/UPDATE rotarians SET lead=if(lead=1,0,1) WHERE rotarian_id=?/;
        return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
        $self->dbh->do($sql, {}, $self->param('id')) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
        return $self->to_json({sc=>'true',msg=>""});
}

sub leaders_GET : StartRunmode {
	my $self = shift;
	return $self->to_json({page => undef, total => undef, records => undef, rows => $self->dbh->selectall_arrayref("select rotarian_id, concat_ws(', ', lastname,firstname) rotarian, lead from rotarians", {Slice=>{}})});
}

1;
