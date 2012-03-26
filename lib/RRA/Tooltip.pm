package RRA::Tooltip;

# THIS IS A TEMPORARY SOLUTION TO TOOLTIPS!!!!!!

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub tooltip_GET : Runmode RequireAjax {
	my $self = shift;
        my ($sql, @bind) = sql_interp 'SELECT item_id,item_id id,number,itemurl,item,description,auctioneer,value,highbid,startbid,minbid,highbidder,bellringer,timerminutes timer,donor,donorurl,advertisement,advertisement message FROM items_current_vw WHERE (status="Bidding" OR status="Sold") ORDER BY number';
        return $self->return_json({rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub return_json {
        my $self = shift;   
        my $data = shift;

        my @data;
        foreach my $row ( @{$data->{rows}} ) {
                # if((find_in_set('newbid',`items`.`notify`) > 0),1,NULL) `newbid`
                # if((`items`.`status` = 'Sold'),1,NULL) `sold`
                $row->{img} = (glob($self->cfg('PHOTOS')."$row->{year}/$row->{number}.*"))[0] if $row->{number};
                if ( $self->cfg('FAKEBIDDING') ) {
                        my @notify = ();
                        if ( int(rand(99)) < 25 ) {
                                $row->{status} = 'Ready';
                        } elsif ( int(rand(99)) < 25 ) { 
                                $row->{status} = 'OnDeck';
                                $row->{auctioneer} = int(rand(99)) < 50 ? 'a' : 'b';
                        } elsif ( int(rand(99)) < 25 ) {
                                $row->{status} = 'Bidding';
                                push @notify, 'newbid' if int(rand(99)) < 20;
                                if ( int(rand(99)) < 25 ) {
                                        push @notify, 'starttimer';
                                } elsif ( int(rand(99)) < 25 ) {
                                        push @notify, 'sell';      
                                }
                                $row->{auctioneer} = int(rand(99)) < 50 ? 'a' : 'b';
                                $row->{highbid} ||= $row->{value} - 10 + int(rand(15));
                                $row->{bellringer} = $row->{highbid} >= $row->{value};
                                $row->{bidder} = $row->{donor};
                                $row->{timer} = int(rand(99)) < 20 ? 1 : 0;
                        } elsif ( int(rand(99)) < 25 ) {
                                $row->{status} = 'Sold';
                        } elsif ( int(rand(99)) < 25 ) {
                                $row->{status} = 'Complete';
                        }
                        $row->{description} ||= int(rand(99)) < 20 ? 'Fuller description' : undef;
                        $row->{itemurl} ||= int(rand(99)) < 20 ? 'http://google.com' : undef;
                        $row->{donorurl} ||= int(rand(99)) < 20 ? 'http://google.com' : undef;
                        $row->{img} ||= int(rand(99)) < 20 ? 'http://dev.washingtonrotary.com/rra/img/right_arrow_button.gif' : undef;
                        $row->{notify} = join ',', @notify;
                }
                $row->{notify} = {map { $_ => 1 } split /,/, $row->{notify}};
                push @data, {map { $_ => $row->{$_}||'' } keys %$row};
        }
        return $self->to_json({count=>$#data+1, rows=>[@data]});
}

1;
