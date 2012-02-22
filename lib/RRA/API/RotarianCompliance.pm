package RRA::API::RotarianCompliance;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub compliance_POST : Runmode {
        my $self = shift;
	my $sql = q/INSERT INTO rotarian_compliance (rotarian_id, year, compliance) VALUES (?, auction_year(), 1) on duplicate key update compliance=if(compliance=1,0,1)/;
        return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
        $self->dbh->do($sql, {}, $self->param('id')) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
        return $self->to_json({sc=>'true',msg=>""});
}

sub compliance_GET : StartRunmode {
	my $self = shift;
	return $self->to_json({page => undef, total => undef, records => undef, rows => $self->dbh->selectall_arrayref("select rotarian_id, concat_ws(', ', lastname,firstname) rotarian, compliance from rotarian_compliance_cy", {Slice=>{}})});
}

1;
