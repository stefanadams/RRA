package RRA;

use base 'CGI::Application::Loaded';

use RRA::Bidder;

# Browser sends creds to login
# Server stores cred in session
# Browser sets cookie for bidder
# Server uses authz(:operators)?postdata||cookie||session:session

# Session contains all user info (including bidder info)
# Cookie contains minimal bidder info
# Browser sends username/phone in cookie
# Server, when using the cookie, looks up bidder info

use strict;
use warnings;

sub _expand_group {
	my ($groups, $group) = @_;

	my %groups = %$groups;
	$group =~ s/^://;
	push @{$groups{$group}}, _expand_group(\%groups, $_) foreach grep { /^:/ } @{$groups{$group}};
	return grep { /^(?!:)/ } @{$groups{$group}};
}

sub cgiapp_init {
	my $self = shift;

	$self->cfg_file($ENV{CONFIG});
	chdir $self->cfg('TEMPLATES');
	my %cfg = $self->cfg;
	$ENV{$_} = $cfg{$_} foreach keys %cfg;
	$self->template->config(
		default_type => 'TemplateToolkit',
		include_paths => $self->cfg('TEMPLATES'),
		TemplateToolkit => {
			EVAL_PERL => 1,
		},
		template_filename_generator => 	sub {
			my $self     = shift;
			my $run_mode = $self->get_current_runmode;
			$run_mode    =~ s/_[A-Z]+$//;
			my $module   = ref $self;
			my @segments = split /::/, $module;
			$self->dumper(File::Spec->catfile(@segments, $run_mode));
			return File::Spec->catfile(@segments, $run_mode);
		},
	);
	$self->session_config(
		CGI_SESSION_OPTIONS => [ "driver:mysql", $self->query, {Handle=>$self->dbh} ],
	);
	my %users = %{$self->cfg('USERS')};
	my %groups = %{$self->cfg('GROUPS')};
	$self->authen->config(
		DRIVER => ['Generic', sub { #DBify
			if ( 1 && $ENV{HTTP_USER_AGENT} =~ /^curl: (\w+) (\w+)$/ ) {	# Allow backdoor?  Have your browser set the user-agent to "curl: username password"
				#print STDERR "Authen Backdoor: $1 -=- $2 -=- $users{$1}\n";
				return 1 if $1 && $2 && $users{$1} && $users{$1} eq $2;	# As long as you supply a valid user/pass, you'll be authorized for any runmode
			}
			my ($user, $password) = @_;
			return $user if $password && $users{$user} && $password eq $users{$user};
			return undef;
		}],
		CREDENTIALS => ['username', 'password'],	# This is the names of the POST keys that will be checked and presented by loginbox
		STORE => 'Session',
		LOGIN_RUNMODE => 'login',
	);
	$self->authz->config(
		DRIVER => ['Generic', sub { #DBify - put users in groups
			my ($user, $group) = @_;
			# This anonymous sub should return 0 or 1
			if ( 1 && $ENV{HTTP_USER_AGENT} =~ /^curl: (\w+) (\w+)$/ ) {	# Allow backdoor?  Have your browser set the user-agent to "curl: username password"
				#print STDERR "Authz Backdoor: $1 -=- $2 -=- $users{$1}\n";
				return 1 if $1 && $2 && $users{$1} && $users{$1} eq $2;	# As long as you supply a valid user/pass, you'll be authorized for any runmode
			}
			return 1 if $user && !$group;
			return 0 if !$user;
			foreach my $g ( split /,/, $group ) {
				# Make all users members of their own group, so you can Authz('username')
				# If authen->username is a member of a group, then authorize (allows groups to be members of groups with _expand_group)
				return 1 if $user eq $g || grep { $_ eq $user } _expand_group(\%groups, $g);
			}
			return 0;
		}],
		FORBIDDEN_RUNMODE => 'login_before_forbid',	# must be a scalar name of a Runmode which should forward to a runmode or return the HTML of a forbidden page or login page
	);
	$self->log_config(
		APPEND_NEWLINE => 1,
		LOG_DISPATCH_MODULES => [
		{
			module		=> 'Log::Dispatch::File',	# Change to MySQL?
			name		=> 'messages',
			filename	=> '/tmp/cap-debug.log',
			min_level	=> 'debug',
			append_newline	=> 1,
			mode		=> 'append',
		}],
	) if $self->cfg('DEBUG');
}

sub cgiapp_prerun {
	my $self = shift;

	$self->param('t0', [gettimeofday]);

}

sub cgiapp_postrun {
	my $self = shift;
	my $output_ref = shift;

	if ( $self->is_ajax ) {
		if ( 1 || 'REQUEST application/json' ) {
			$self->header_add(-type => 'application/json');
			my $json = $self->to_json($$output_ref);
			$$output_ref = $json;
		}
	}

	$self->param('t1', [gettimeofday]);
	$self->param('t', tv_interval($self->param('t0'), [gettimeofday])),

	return $output_ref;
}

sub error_rm : ErrorRunmode Runmode {
	my $self = shift;
	if ( $self->is_ajax ) {
		return $self->return_json({error => 500, title => 'Technical Failure', msg => 'There was a technical failure: '.shift});
	} else {
		return $self->error(title => 'Technical Failure', msg => 'There was a technical failure: '.shift);
	}
}

# Forward to a runmode or return HTML
sub login_before_forbid : Runmode {
	my $self = shift;
	return $self->forward('login');
}

1;
