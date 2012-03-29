package CGI::Application::Plugin::Request;

# Stolen from CAP:AutoRunmode and CAP:RequireSSL

use warnings;
use strict;
use Carp;
use SQL::Interp ':all';
use Switch;
use base 'Exporter';
our @EXPORT = qw[requests request approve];

our $VERSION = '0.01';

sub requests {
	my $self = shift;
	my ($sql, @bind) = sql_interp 'SELECT request_id,request,value,approve FROM requests WHERE approve IS NULL';
	return {requests => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)} or return undef;
}

sub request {
	my $self = shift;
	my ($request, $value) = @_;
	my ($sql, @bind) = sql_interp 'INSERT INTO requests',{session_id=>$self->session->id,request=>$request,value=>$value};
       	$self->dbh->do($sql, {}, @bind) or return undef;
	($sql, @bind) = sql_interp 'SELECT request_id,request,value,approve FROM requests WHERE',{session_id=>$self->session->id,request=>$request,value=>$value};
	return {request => $self->dbh->selectrow_hashref($sql, {}, @bind)} or return undef;
}

sub approve {
	my $self = shift;
	my ($request_id, $approve) = @_;
	if ( $approve =~ /^[01]$/ ) {
		my ($sql, @bind) = sql_interp 'DELETE FROM requests WHERE',{request_id=>$request_id};
		#my ($sql, @bind) = sql_interp 'UPDATE requests SET',{approve=>$approve},'WHERE',{request_id=>$request_id};
        	$self->dbh->do($sql, {}, @bind) or return undef;
	        return $approve;
	} else {
	        return undef;
	}
}

#sub ack {
#	my $self = shift;
#	my ($request_id, $ack) = @_;
#	switch ( $ack ) {
#		case 'request' {
#			my ($sql, @bind) = sql_interp 'SELECT request_id,request,value,approve FROM requests WHERE',{request_id=>$request_id};
#			my $request = $self->dbh->selectrow_arrayref($sql, {Slice=>{}}, @bind) or return undef;
#			($sql, @bind) = sql_interp 'UPDATE requests SET ack=1 WHERE',{request_id=>$request_id};
#			$self->dbh->do($sql, {}, @bind) or return undef;
#			return $request;
#		}
#		case 'approve' {
#			my ($sql, @bind) = sql_interp 'SELECT request_id,request,value,approve FROM requests WHERE',{request_id=>$request_id};
#			my $request = $self->dbh->selectrow_arrayref($sql, {Slice=>{}}, @bind) or return undef;
#			($sql, @bind) = sql_interp 'DELETE FROM requests WHERE',{request_id=>$request_id};
#			$self->dbh->do($sql, {}, @bind) or return undef;
#			return $request;
#		}
#		else {
#	        	return undef;
#		}
#	}
#}

1;
