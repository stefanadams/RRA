package RRA::Base;

our $VERSION = '0.01';

use strict;
use warnings;

use base 'CGI::Application';
use Apache2::RequestIO ();
use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::Authorization;
use CGI::Application::Plugin::ConfigAuto (qw/cfg cfg_file/);
use CGI::Application::Plugin::ErrorPage 'error';
use CGI::Application::Plugin::AutoRunmode;
use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::Forward;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::DBH qw/dbh_config dbh/;
use CGI::Application::Plugin::AnyTemplate;
use CGI::Application::Plugin::DetectAjax;
use CGI::Application::Plugin::JSON ':all';
use CGI::Application::Plugin::RequireAjax 'requires_ajax';
use CGI::Application::Plugin::RequireSSL 'mode_redirect';
use CGI::Application::Plugin::Stream (qw/stream_file/);
use CGI::Application::Plugin::Request;

use CGI::Application::Plugin::LogDispatch;
#use CGI::Application::Plugin::DevPopup;
#use CGI::Application::Plugin::DevPopup::Timing;
#use CGI::Application::Plugin::DevPopup::HTTPHeaders;
#use CGI::Application::Plugin::DevPopup::Params;
#use CGI::Application::Plugin::DebugScreen;
#use CGI::Application::Plugin::ViewCode;

#use Switch;
use Time::HiRes qw/gettimeofday tv_interval/;
use Data::Dumper;

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
		template_filename_generator => \&template_filename_generator,
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
			module		=> 'Log::Dispatch::File',
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

	my $current = $self->dbh->selectrow_hashref('SELECT * FROM auctions_current_vw');
	$self->param('year', $current->{year});
	$self->param('night', $current->{night});
	$self->param('live', $current->{live});
	unless ( $current->{live} ) {
		my $next = $self->dbh->selectrow_hashref('SELECT * FROM auctions_next_vw');
		$self->param('year_next', $next->{year});
		$self->param('night_next', $next->{night});
		$self->param('date_next', $next->{date});
	}

	# Split contact into two contacts
	if ( $self->query->param('contact') ) {
		my @contacts = split /\|/, $self->query->param('contact');
		$self->query->param('contact1', $contacts[0]) if $contacts[0];
		$self->query->param('contact2', $contacts[1]) if $contacts[1];
	}

	# Build param() with all of the data sent from the browser
	my $DATA = {};
	$self->param('mod_perl', $ENV{MOD_PERL});
	$self->param('http_referer', $ENV{HTTP_REFERER});
	if ( $self->query->request_method eq 'POST' ) {
		if ( !$self->query->content_type || $self->query->content_type =~ m!^application/x-www-form-urlencoded! || $self->query->content_type =~ m!multipart/form-data! ) {
			$DATA = { map { $_ => $self->query->param($_) } $self->query->param };
		} elsif ( $self->query->content_type =~ m!^application/json! ) {
			$DATA = $self->from_json($self->query->param('POSTDATA')) if $self->query->param('POSTDATA');
		}
	} elsif ( $self->query->request_method eq 'GET' ) {
		$DATA = { map { $_ => $self->query->param($_) } $self->query->param };
	}
	if ( $self->param('dispatch_url_remainder') ) {
		$DATA->{path_info} = [split m!/!, $self->param('dispatch_url_remainder')];
	}
	if ( $self->query->path_info ) {
		$DATA->{app} ||= (split m!/!, $self->query->path_info)[1];
		$DATA->{rm} ||= (split m!/!, $self->query->path_info)[2];
	}
	if ( $DATA->{me} = $ENV{REQUEST_URI} ) {
		$DATA->{me} =~ s!/$_$!! if local $_ = $self->param('dispatch_url_remainder');
	}
	$self->param('t0', [gettimeofday]);

	$self->param($_, $DATA->{$_}) foreach keys %{$DATA};

	#print STDERR Dumper($DATA);
}

sub cgiapp_postrun {
	my $self = shift;
	my $o = shift;

	$self->dumper({
		STATEMENT => $self->dbh->{Statement},
		TIME => join(' - ', $$, scalar localtime),
		RM_TIME => tv_interval($self->param('t0'), [gettimeofday]),
		ARGS => $self->param('dispatch_url_remainder'),
		REQUEST_URI => $ENV{REQUEST_URI},
		PATH_INFO => $ENV{PATH_INFO},
		REQUEST_METHOD => $ENV{REQUEST_METHOD},
		CONTENT_TYPE => $ENV{CONTENT_TYPE},
#		DATA => $self->param('DATA') || undef,
		AJAX => $ENV{HTTP_X_REQUESTED_WITH} && $ENV{HTTP_X_REQUESTED_WITH} eq 'XMLHttpRequest' ? 'yes' : 'no',
		POSTDATA => $self->query->param('POSTDATA')||'',
		PARAM => { map { $_ => $self->param($_) } grep { !/^__/ } $self->param },
	});
}

sub error_rm : ErrorRunmode Runmode {
	my $self = shift;
	if ( $self->is_ajax ) {
		return $self->return_json({error => 500, title => 'Technical Failure', msg => 'There was a technical failure: '.shift});
	} else {
		return $self->error(title => 'Technical Failure', msg => 'There was a technical failure: '.shift);
	}
}

sub template_filename_generator {
	my $self     = shift;
	my $run_mode = $self->get_current_runmode;
	$run_mode    =~ s/_[A-Z]+$//;
	my $module   = ref $self;
	my @segments = split /::/, $module;
	$self->dumper(File::Spec->catfile(@segments, $run_mode));
	return File::Spec->catfile(@segments, $run_mode);
}

# Forward to a runmode or return HTML
sub login_before_forbid : Runmode {
	my $self = shift;
	return $self->forward('login');
}

sub login_GET : Runmode {
	my $self = shift;
	return $self->forward('login');
}
sub login_POST : Runmode {
	my $self = shift;
	return $self->forward('login');
}

sub login : Runmode {
	my $self = shift;
	if ( $self->authen->username ) {
		if ( $self->is_ajax ) {
			return $self->return_json({error => 401});
		} else {
			return join("\n",
				CGI::start_html(-title => 'Unauthorized'),
				CGI::h2('Unauthorized'),
				CGI::p('You do not have permission to perform that action'),
				CGI::end_html(),
			);
		}
	} else {
		if ( $self->is_ajax ) {
			return $self->return_json({error => 403});
		} else {
			return $self->authen->login_box;
		}
	}
}

sub logout_GET : Runmode {
	my $self = shift;
	return $self->forward('logout');
}
sub logout_POST : Runmode {
	my $self = shift;
	return $self->forward('logout');
}

sub logout : Runmode {
	my $self = shift;
	$self->authen->logout;
	return join(
		"\n",
		CGI::start_html(-title => 'Signed Out!'),
		CGI::h2('Signed Out'),
		CGI::a({href=>'/rra/login.html'}, "Sign In"),
		CGI::end_html(),
	);
}

sub about {
        my $self = shift;
        my ($dbname) = ($self->dbh->{Name} =~ /^([^;]+)/);
        return {
		about => {
	                name => 'Washington Rotary Radio Auction',
        	        version => $VERSION,
                	database => $dbname,
	                dev => $dbname =~ /_dev$/ ? 1 : 0,
        	        time => join(' - ', $$, scalar localtime),
                	rm_time => tv_interval($self->param('t0'), [gettimeofday]),
	                username => $self->authen->username,
        	        year => $self->param('year'),
                	night => $self->param('night'),
	                live => $self->param('live'),
        	        year_next => $self->param('year_next') || undef,
                	night_next => $self->param('night_next') || undef,
	                date_next => $self->param('date_next') || undef,
		},
		header => {
	                play => $self->cfg('PLAY'),
		},
        };
}

sub about_GET : Runmode RequireAjax {
        my $self = shift;
        return $self->return_json($self->about->{$self->param('about')||'about'}||{});
}

######
######

sub return_json {
	my $self = shift;
	$self->header_add(
		-type => 'application/json',
	);
	return $self->to_json(@_);
}

sub sOper { ('eq' => '=', 'ne' => '<>', 'lt' => '<', 'le' => '<=', 'gt' => '>', 'ge' => '>=', 'bw' => " LIKE '%'", 'ew' => " LIKE '%'", 'cn' => " LIKE '%%'") }

sub dumper {
	my $self = shift;
	$self->log->debug(join "\n", map { ref $_ ? Dumper($_) : $_ } @_) if $self->cfg('DEBUG');
}

sub env {
	my $self = shift;
	return $ENV{$_[0]};
}

sub _expand_group {
	my ($groups, $group) = @_;

	my %groups = %$groups;
	$group =~ s/^://;
	push @{$groups{$group}}, _expand_group(\%groups, $_) foreach grep { /^:/ } @{$groups{$group}};
	return grep { /^(?!:)/ } @{$groups{$group}};
}

1;
