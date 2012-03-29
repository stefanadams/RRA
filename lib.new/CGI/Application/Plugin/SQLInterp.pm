package CGI::Application::Plugin::SQLInterp;

# Stolen from CAP:AutoRunmode and CAP:RequireSSL

use warnings;
use strict;
use Carp;
use SQL::Interp ':all';
use base 'Exporter';
our @EXPORT = qw[sql_interp];

our $VERSION = '0.01';

sub sql_interp {
	my $self = shift;

	my ($sql, @bind) = sql_interp @_;
	return $_[0], undef, @bind;
}

sub sql {
	my $self = shift;

	my ($sql, @bind) = sql_interp @_;
	return $_[0], undef, @bind;
}

sub selectall_arrayref {
	my $self = shift;

	return {page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub selectall_hashref {
	my $self = shift;

	return {page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub selectrow_array {
	my $self = shift;

	return {page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub selectrow_arrayref {
	my $self = shift;

	return {page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

sub selectrow_hashref {
	my $self = shift;

	return {page => $page, total => $pages, records => $records, rows => $self->dbh->selectall_arrayref($sql, {Slice=>{}}, @bind)});
}

1;
