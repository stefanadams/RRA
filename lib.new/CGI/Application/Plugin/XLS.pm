package CGI::Application::Plugin::WriteExcel;

# Stolen from CAP:AutoRunmode and CAP:RequireSSL

use warnings;
use strict;
use Carp;
use Spreadsheet::WriteExcel;
use base 'Exporter';
our @EXPORT = qw[writeexcel];

our $VERSION = '0.01';

sub writeexcel {
	my $self = shift;
        $self->header_add(-type => 'application/vnd.ms-excel');
        return Spreadsheet::WriteExcel->new(@_);
}

1;
