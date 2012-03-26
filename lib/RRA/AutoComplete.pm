package RRA::AutoComplete;
use base 'RRA::Base';

use Switch;
use SQL::Interp ':all';

sub ac_GET : Runmode RequireAjax {
	my $self = shift;
	my ($for) = split /\//, $self->param('dispatch_url_remainder');
 
	my $q = $self->param('q') || '';
	my $ac = {};
	$self->param('donor_id', $1||'') if $self->param('donor') && $self->param('donor') =~ /:(\d+)$/;
	$self->param('stockitem_id', $1||'') if $self->param('stockitem') && $self->param('stockitem') =~ /:(\d+)$/;
	my $limit = $self->param('limit') || 10;
	my ($sql, @bind);
	my $new = 0;
	switch ( $for ) {
		case 'city' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_city_vw WHERE city LIKE',\"$q%",'LIMIT', \$limit;
		}
		case 'donor' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_donor_vw WHERE donor LIKE',\"$q%",'OR', {donor_id=>$q}, 'LIMIT', \$limit;
		}
		case 'advertiser' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_advertiser_vw WHERE advertiser LIKE',\"$q%",'OR', {advertiser_id=>$q}, 'LIMIT', \$limit;
		}
		case 'item_stockitem' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_item_stockitem_vw WHERE stockitem LIKE',\"%$q%",'LIMIT', \$limit;
		}
		case 'item' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_item_vw WHERE',{number=>$q},'OR item LIKE',\"%$q%",'OR donor LIKE',\"$q%",'OR',{donor_id=>$q},'OR',{item_id=>$q},'LIMIT', \$limit;
		}
		case 'ad' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_ad_vw WHERE',{number=>$q},'OR ad LIKE',\"%$q%",'OR advertiser LIKE',\"$q%",'OR',{advertiser_id=>$q},'OR',{ad_id=>$q},'LIMIT', \$limit;
		}
		case 'advertisement' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_advertisement_vw WHERE',{donor_id=>$q},'OR advertisement LIKE',\"%$q%",'LIMIT', \$limit;
		}
		case 'stockitem' {
			($sql, @bind) = sql_interp 'SELECT ac FROM ac_stockitem_vw WHERE stockitem LIKE',\"%$q%",'LIMIT', \$limit;
		}
		case 'pay_number' {
			$new = 1;
			my $term = $self->param('term');
			($sql, @bind) = sql_interp 'SELECT * FROM ac_pay_number_vw WHERE', {value=>$term}, 'OR label LIKE',\"%$term%", 'ORDER BY value LIMIT', \$limit;
		}
		case 'bid' {
			my $term = $self->query->param('term');
			my $limit = $self->query->param('limit') || 10;
			my $ac;
			my @ac = ();
			switch ( $self->param('field') ) {
				case 'name' {
					if ( $term =~ /^\d+$/ ) {
						my ($a, $b, $c);
						if ( length($term) == 3 ) {
							$b = $term;
						} elsif ( length($term) == 4 ) {
							$c = $term
						} elsif ( length($term) > 4 && length($term) <= 7 ) {
							my ($b, $c) = ($term =~ /^(\d{3})(\d{0,4})$/);
						} elsif ( length($term) > 7 && length($term) <= 10 ) {
							my ($a, $b, $c) = ($term =~ /^(\d{3})(\d{2,3})(\d{0,4})$/);
						}
						$a .= '_' while length($a) < 3;
						$b .= '_' while length($b) < 3;
						$c .= '_' while length($c) < 4;
						$ac = $self->dbh->selectall_hashref("SELECT bidder_id id,name,phone FROM bidders_vw WHERE phone LIKE '(?) ?-?' OR phone LIKE '???' ORDER BY name LIMIT $limit", "id", undef, $a, $b, $c, $a, $b, $c);
					} else {
						$ac = $self->dbh->selectall_hashref("SELECT bidder_id id,name,phone FROM bidders_vw WHERE name LIKE ? ORDER BY name LIMIT $limit", "id", undef, "%$term%");
					}
					foreach my $id ( keys %{$ac} ) {
						push @ac, join '|', map { $_ eq 'name' ? $ac->{$id}->{$_} || '' : join ':', $_, ($ac->{$id}->{$_} || '') } qw/name phone id/;
					}
				}
			}
			return join "\n", @ac;
		}
	}
	print STDERR "\n\n\n\n\n$sql\n\n\n\n\n\n";
	if ( $new ) {
		my $ac = $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind);
		return $self->to_json(\@$ac);
	} else {
		$ac = $self->dbh->selectall_arrayref($sql, {}, @bind);
		return join "\n", map { @$_ } @$ac;
	}
}

1;
