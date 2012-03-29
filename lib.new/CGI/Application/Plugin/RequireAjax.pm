package CGI::Application::Plugin::RequireAjax;

# Stolen from CAP:AutoRunmode and CAP:RequireSSL

use warnings;
use strict;
use Carp;
use base 'Exporter';
use Attribute::Handlers;
our @EXPORT_OK = qw[MODIFY_CODE_ATTRIBUTES requires_ajax];
our %RUNMODES;

use Class::ISA ();
use Scalar::Util ();
use UNIVERSAL::require;

our $VERSION = '0.01';

# The attribute name is declared here in the sub name
sub CGI::Application::RequireAjax : ATTR(CODE, BEGIN, CHECK) {
	my ($pkg, $glob, $ref, $attr, $data, $phase) = @_;
	no strict 'refs';
	$RUNMODES{"$ref"} = 1;
}

sub MODIFY_CODE_ATTRIBUTES {
	my ($pkg, $ref, @attr) = @_;
	foreach ( @attr ) {
		if ( uc $_ eq 'REQUIREAJAX' ) {
			$_ = 'RequireAjax'; 
			next;
		}
	}
	return $pkg->SUPER::MODIFY_CODE_ATTRIBUTES($ref, @attr);
}

sub import {
	__PACKAGE__->export_to_level(1, @_, 'MODIFY_CODE_ATTRIBUTES');
	my $caller = scalar(caller);
	$caller->add_callback(init   => sub { shift->run_modes(['requires_ajax']) });
	$caller->add_callback(prerun => \&cgiapp_prerun);
	goto &Exporter::import;
}

sub cgiapp_prerun{
	my ($self, $rm) = @_;   
	# If prerun_mode has been set, use it!
	my $prerun_mode = $self->prerun_mode();
	if ( length($prerun_mode) ) {
		$rm = $prerun_mode;
	}
	return unless defined $rm;

	# This is where we decide if the request complies with the Attribute specified.
	my $is_ajax = exists $ENV{HTTP_X_REQUESTED_WITH} && lc $ENV{HTTP_X_REQUESTED_WITH} eq 'xmlhttprequest' ? 1 : 0;
	return $self->prerun_mode('requires_ajax') if is_attribute_require_ajax($self, $rm) && !$is_ajax;
}

sub is_attribute_require_ajax {
	my($app, $rm) = @_;   
	my $sub = $app->can($rm);
	return unless $sub;
	return $sub if $RUNMODES{"$sub"};
	return undef;
}

sub requires_ajax {
	my $self = shift;
	die "Requires Ajax!\n";
}

1;
