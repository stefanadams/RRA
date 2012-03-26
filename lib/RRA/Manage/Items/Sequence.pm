package RRA::Manage::Items::Sequence;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub sequence_GET : StartRunmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my ($sql, @bind);
	my $n = $self->param('n');
	if ( $n =~ /^\d+$/ ) {
		if ( $n == 9999 ) {
			($sql, @bind) = sql_interp 'SELECT concat(item," -- Night ",scheduled,", ",if(isnull(seq),"Sequence Undefined",concat("Sequence ",seq))) item FROM manage_items_sequence_vw ORDER BY number';
		} elsif ($n == 0) {
			($sql, @bind) = sql_interp 'SELECT * FROM manage_items_sequence_vw WHERE night IS NULL';
		} else {
			($sql, @bind) = sql_interp 'SELECT * FROM manage_items_sequence_vw WHERE', {night=>$n};
		}
	} else {
		($sql, @bind) = sql_interp 'SELECT * FROM manage_items_sequence_tablabels_vw';
	}
	return $self->to_json({rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub sequence_POST : Runmode RequireAjax Authen Authz(':admins') {
	my $self = shift;
	my $n = $self->param('n');
	my @item_id = map { /_(\d+)$/; $1 } @{$self->param('item_id')};
	my ($sql, @bind);
	if ( $n == 0 ) {
		($sql, @bind) = sql_interp 'UPDATE items SET `items`.`scheduled`=null,seq = FIND_IN_SET(item_id, ', \join(',', @item_id), ') WHERE item_id IN', \@item_id;
	} else {
		($sql, @bind) = sql_interp 'UPDATE items SET `items`.`scheduled`=night2date(',\$n,'),seq = FIND_IN_SET(item_id, ', \join(',', @item_id), ') WHERE item_id IN', \@item_id;
	}
	return $self->to_json({sc=>'false',msg=>"Sequencing Disabled"}) if $self->cfg('NOSEQ');
	return $self->to_json({sc=>'false',msg=>"Editing disabled"}) if $self->cfg('NOEDIT');
	$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
#return $self->to_json({sc=>'true',msg=>""});
	($sql, @bind) = sql_interp 'SELECT * FROM manage_items_sequence_tablabels_vw';
	return $self->to_json({sc=>'true', rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
