package Rotary::Auction::Jqgrid;

use strict;
use warnings;

use base 'Rotary::Auction';
use Switch;
use SQL::Interp ':all';

my %sOper = (
	'eq' => '=?',
	'ne' => '<>?',
	'lt' => '<?',
	'le' => '<=?',
	'gt' => '>?',
	'ge' => '>=?',
	'bw' => " LIKE '?%'",
	'ew' => " LIKE '%?'",
	'cn' => " LIKE '%?%'",
);

sub num { $_ = shift; s/\D//g; return $_; }

########

sub start_GET : StartRunmode { shift->template->fill }

sub donors_GET : Runmode { $_[0]->template->fill({c=>$_[0]}) }
sub donors_POST : Runmode { #Ajax Authen Authz('admins') {
	my $self = shift;

	my @donor = qw/donor_id chamberid phone donor category contact1 contact2 address city state zip email url advertisement solicit comments rotarian_id/;
	switch ( $self->param('oper') ) {
		case 'add' {
			my ($sql, @bind) = sql_interp 'INSERT INTO donors', {map {$_=>$self->param($_)} @donor};
			$self->dumper([$sql, @bind]);
			$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
			return $self->to_json({sc=>'true',msg=>""});
		}
		case 'del' {
			my ($sql, @bind) = sql_interp 'DELETE FROM donors WHERE donor_id = ', $self->param('id');
			$self->dumper([$sql, @bind]);
			$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
			return $self->to_json({sc=>'true',msg=>""});
		}
		case 'edit' {
			my ($sql, @bind) = sql_interp 'UPDATE donors SET', {map {$_=>$self->param($_)} $self->param('celname')}, ' WHERE donor_id = ', $self->param('id');
			$self->dumper([$sql, @bind]);
			$self->dbh->do($sql, {}, @bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
			return $self->to_json({sc=>'true',msg=>""});
		}
		else {
			my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'donor', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
			my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
			my $search = 'WHERE donor="" or phone="(999) 999-9999" or address="" or city=""' if $sField && $sOper && !$sValue; # Easter Egg Advanced Search
			if ( my $donor_id = $self->param('id') ) {
				# Subgrid
				my $records = $self->dbh->selectrow_array("SELECT COUNT(*) count FROM items WHERE donor_id=?", {}, $donor_id);
				my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'donor', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
				my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
				my $start = $page * $rows - $rows || 0;
				my ($sql, @bind) = ("SELECT * FROM donors_items_vw WHERE donor_id=? LIMIT 0,20", $donor_id);
				$self->dumper([$sql, @bind]);
				my $sth = $self->dbh->prepare($sql);
				$sth->execute(@bind) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
				my $i = 0;
				my $json = {};
				while ( my @row = $sth->fetchrow_array ) {
					$json->{rows}->[$i]->{id} = $row[2];
					$json->{rows}->[$i]->{cell} = [@row];
					$i++;
				}
				return $self->to_json($json);
			} else {
				# Master grid
				$search ||= "WHERE $sField$sOper{$sOper}" if $sField && $sOper{$sOper};
				my $records = $self->dbh->selectrow_array("SELECT COUNT(*) count FROM donors_vw $search", {}, ($sField && $sOper{$sOper} && $sValue ? $sValue : ()));
				my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
				my $start = $page * $rows - $rows || 0;
				my ($sql, @bind) = ("SELECT * FROM donors_vw $search ORDER BY $sidx $sord LIMIT ?,?", ($sField && $sOper{$sOper} && $sValue ? $sValue : ()), $start, $rows);
				$self->dumper([$sql, @bind]);
				return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
			}
		}
	}
}

sub items_GET : Runmode { $_[0]->template->fill({c=>$_[0]}) }
sub items_POST : Runmode { #Authen Authz('admins') {
	my $self = shift;

	$self->param('donor_id', $1||'') if $self->param('donor') && $self->param('donor') =~ /:(\d+)$/;
	$self->param('stockitem_id', $1||'') if $self->param('stockitem') && $self->param('stockitem') =~ /:(\d+)$/;
	switch ( $self->param('oper') ) {
		case 'add' {
			my ($sth, $row);
			$sth = $self->dbh->prepare("SELECT name FROM donors_vw WHERE donor_id=?");
			eval { $sth->execute($self->query->param('donor_id')); } or return $self->to_json({sc=>'false',msg=>"Error: ".$sth->errstr});
			$row = $sth->fetchrow_hashref;
			$self->query->param('sellername', $row->{name});
			# Race condition starts
			$sth = $self->dbh->prepare("SELECT MAX(number)+1 number FROM items_vw");
			eval { $sth->execute($self->query->param('year')); } or return $self->to_json({sc=>'false',msg=>"Error: ".$sth->errstr});
			$row = $sth->fetchrow_hashref;
			my $number = $row->{number} || 100;
			$self->query->param('number', $number);
			$sth = $self->dbh->prepare("INSERT INTO items (id, year, number, category, name, description, value, seq, advertisement, url, donor_id, stockitem_id) VALUES (null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
			eval { $sth->execute(map { $self->query->param($_) || undef } qw/year number category name description value number advertisement url donor_id stockitem_id/); } or return $self->to_json({sc=>'false',msg=>"Error: ".$sth->errstr});
			# Race condition ends
			return $self->to_json({sc=>'false',msg=>$self->dbh->err}) if $self->dbh->err;
			return $self->to_json({sc=>'true',number=>$self->query->param('number'), msg=>""});
		}
		case 'del' {
			$self->dbh->do("DELETE FROM items WHERE year=? AND item_id=?", {}, $self->param('year'), $self->param('id')) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
			return $self->to_json({sc=>'true',msg=>""});
		}
		case 'edit' {
			my $celname = $self->param('celname');
			$self->dbh->do("UPDATE donors SET $celname=? WHERE item_id=?", {}, $self->param($celname), $self->param('id')) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
			return $self->to_json({sc=>'true',msg=>""});
			my ($sth, $row);
		}
		else {
			my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'item', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
			my ($sField, $sOper, $sValue) = ($self->param('searchField'), $self->param('searchOper'), $self->param('searchString'));
			my $search = "WHERE $sField$sOper{$sOper}" if $sField && $sOper{$sOper};
			my $records = $self->dbh->selectrow_array("SELECT COUNT(*) count FROM items_vw $search", {}, ($sField && $sOper{$sOper} && $sValue ? $sValue : ()));
			my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
			my $start = $page * $rows - $rows || 0;
			my ($sql, @bind) = ("SELECT * FROM items_vw $search ORDER BY $sidx $sord LIMIT ?,?", ($sField && $sOper{$sOper} && $sValue ? $sValue : ()), $start, $rows);
			$self->dumper([$sql, @bind]);
			return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
		}
	}
}

sub stockitems_GET : Runmode { $_[0]->template->fill({c=>$_[0]}) }
sub stockitems_POST : Runmode { #Authen Authz('admins') {
	my $self = shift;

	switch ( $self->param('oper') ) {
		case 'add' {
			$self->dbh->do("INSERT INTO stockitems (stockitem_id, year, category, name, value, cost) VALUES (null, ?, ?, ?, ?, ?)", {}, map { $self->param($_)||undef } qw/category name value cost/) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
			return $self->to_json({sc=>'true',msg=>""});
		}
		case 'del' {
			$self->dbh->do("DELETE FROM stockitems WHERE stockitem_id = ?", {}, $self->param('id')) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
			return $self->to_json({sc=>'true',msg=>""});
		}
		case 'edit' {
			my $celname = $self->param('celname');
			$self->dbh->do("UPDATE stockitems SET $celname=? WHERE stockitem_id=?", {}, $self->param($celname), $self->param('id')) or return $self->to_json({sc=>'false',msg=>"Error: ".$self->dbh->errstr});
			return $self->to_json({sc=>'true',msg=>""});
		}
		else {
			my $count = $self->dbh->selectrow_hashref("SELECT COUNT(*) count FROM stockitems_vw", {}, $self->param('year'));
			my $records = $count->{count};
			my ($sidx, $sord, $page, $rows) = ($self->param('sidx')||'name', $self->param('sord')||'asc', $self->param('page')||1, $self->param('rows')||10);
			my $pages = $records > 0 ? int(($records / $rows) + 0.99) : 0;
			my $start = $page * $rows - $rows || 1;
			my $sql = "SELECT * FROM stockitems_vw ORDER BY $sidx $sord LIMIT ?,?";
			return $self->to_json({page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, $start, $rows)});
		}
	}
}

sub seqitems_GET : Runmode { $_[0]->template->fill({c=>$_[0]}) }
sub seqitems_POST : Runmode Authen Authz('admins') {
	my $self = shift;

	my ($setnight, $summary) = map { $self->query->param($_)||undef } qw/night summary/;
	if ( $setnight ) {
		if ( $setnight =~ /^(1|2|3|4)$/ ) {
			my $order = join ',', grep { /^\d+$/ } map { $_ } $self->query->param('id[]');
			my $sth = $self->dbh->prepare("UPDATE items SET night=? WHERE year=? AND id IN ($order)");
			$sth->execute($setnight, $self->param('year'));
			$sth = $self->dbh->prepare("UPDATE items SET seq = FIND_IN_SET(id, '$order') WHERE year=? AND night=? AND id IN ($order)");
			$sth->execute($self->param('year'), $setnight);
		}
	} elsif ( $summary ) {
		# Turn into a jTemplate and this should just output JSON
		# Or at least turn into an HTML::Template
		my $OUT = '<table>';
		$OUT .= '<thead><tr><th>Category</th><th>Night 1</th><th>Night 2</th><th>Night 3</th><th>Night 4</th></thead>';
		$OUT .= '<tbody>';
		$OUT .= '<tr>';
		my $sth = $self->dbh->prepare("select night, sum(value) value from items where year=? group by night with rollup");
		$sth->execute($self->param('year'));
		while ( my $row = $sth->fetchrow_hashref ) {
			$OUT .= '<td>'.$row->{value}.'</td>';
		}
		$OUT .= '</tr>';
		foreach ( 'food','gc','travel','personal care','auto','apparel','sports','event tickets','baskets','wine','misc','garden','one per' ) {
			$OUT .= '<tr>';
			$OUT .= '<td>'.$_.'</td>';
			my $sth = $self->dbh->prepare("select night, category, count(*) qty from items where year=? and category=? group by night order by night");
			$sth->execute($self->param('year'), $_);
			while ( my $row = $sth->fetchrow_hashref ) {
				$OUT .= '<td>'.$row->{qty}.'</td>';
			}
			$OUT .= '</tr>';
		}
		$OUT .= '<tr>';
		$OUT .= '<td>N/A</td>';
		$sth = $self->dbh->prepare("select night, category, count(*) qty from items where year=? and category is null group by night order by night");
		$sth->execute($self->param('year'));
		while ( my $row = $sth->fetchrow_hashref ) {
			$OUT .= '<td>'.$row->{qty}.'</td>';
		}
		$OUT .= '</tr>';
		$OUT .= '</tbody>';
		$OUT .= '</table>';
		return $OUT;
	}
}

1;
