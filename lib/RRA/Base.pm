package RRA::Base;

our %users = (
	#username => 'password',
	admin => 'harris',
	adsales => 'harris',
	caller => 'harris',
	bellringer => 'harris',
	auctioneer => 'harris',
	a => 'harris',
	b => 'harris',
	operator => 'harris',
);
our %groups = (
	#group => [qw/user names/],
	admins => [qw/admin/],
	adsales => [qw/adsales :admins/],
	callers => [qw/caller :admins/],
	bellringers => [qw/bellringer :admins/],
	auctioneers => [qw/a b auctioneer :admins/],
	operators => [qw/operator :admins/],
	backend => [qw/:admins :auctioneers :operators/],
);
# @auctioneers = join ',', grep { /^(?!:)/ } @{$groups{auctioneers}}
#our %protected = ( 
#	#page => 'group',
#	admin => 'admins',
#	adsales => 'adsales',
#	caller => 'callers',
#	bellringer => 'bellringers',
#	auctioneer => 'auctioneers',
#	operator => 'operators',
#	resttest_GET => 'admins',
#	resttest_POST => 'admins',
#	resttest_DELETE => 'auctioneers',
#	resttest_PUT => 'admins',
#);

use strict;
use warnings;

use base 'CGI::Application';
use Apache2::RequestIO ();
use CGI::Application::Plugin::ConfigAuto (qw/cfg cfg_file/);
use CGI::Application::Plugin::AutoRunmode;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::DBH qw/dbh_config dbh/;
use CGI::Application::Plugin::AnyTemplate;
use CGI::Application::Plugin::DetectAjax;
use CGI::Application::Plugin::JSON ':all';
use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::Authorization;
use CGI::Application::Plugin::Stream (qw/stream_file/);

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
	my %cfg = $self->cfg;
	$ENV{$_} = $cfg{$_} foreach keys %cfg;
print STDERR "Config: $ENV{CONFIG}\nTEMPLATES: ", $self->cfg('TEMPLATES'), "\n";
	$self->template->config(
		default_type => 'TemplateToolkit',
		include_paths => $self->cfg('TEMPLATES'),
		TemplateToolkit => {
			EVAL_PERL => 1,
		},
		template_filename_generator => \&template_filename_generator,
	);
	$self->authen->config( #DBify
		DRIVER => ['Generic', \%users],
		CREDENTIALS => ['username', 'password'],	# This is the names of the POST keys that will be checked and presented by loginbox
		STORE => 'Session'
	);
	$self->authz->config( # DBify
		DRIVER => ['Generic', sub {
			# This anonymous sub should return 0 or 1
			if ( 1 ) {	# Allow backdoor?  Have your browser set the user-agent to "curl: username password"
				$ENV{HTTP_USER_AGENT} =~ /^curl: (\w+) (\w+)$/;
				return 1 if $1 && $2 && $users{$1} && $users{$1} eq $2;	# As long as you supply a valid user/pass, you'll be authorized for any runmode
			}
			my $user = shift or return 0;
			foreach my $group ( @_ ) {
				# Make all users members of their own group, so you can Authz('username')
				# If authen->username is a member of a group, then authorize (allows groups to be members of groups with _expand_group)
				return 1 if $user eq $group || grep { $_ eq $user } _expand_group(\%groups, $group);	
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

	# Split contact into two contacts
	if ( $self->query->param('contact') ) {
		my @contacts = split /\|/, $self->query->param('contact');
		$self->query->param('contact1', $contacts[0]) if $contacts[0];
		$self->query->param('contact2', $contacts[1]) if $contacts[1];
	}

	# Build param() with all of the data sent from the browser
	my $DATA = {};
	$self->param('mod_perl', $ENV{MOD_PERL});
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
		$DATA->{app} = (split m!/!, $self->query->path_info)[1];
		$DATA->{rm} = (split m!/!, $self->query->path_info)[2];
	}
	if ( $DATA->{me} = $ENV{REQUEST_URI} ) {
		$DATA->{me} =~ s!/$_$!! if local $_ = $self->param('dispatch_url_remainder');
	}
	$self->param($_, $DATA->{$_}) foreach keys %{$DATA};

	$self->param('t0', [gettimeofday]);
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
	if ( $self->authen->username ) {
		if ( $self->is_ajax ) {
			return $self->to_json({error => 403});
		} else {
			return join(
				"\n",
				CGI::start_html(-title => 'Forbidden'),
				CGI::h2('Forbidden'),
				CGI::p('You do not have permission to perform that action'),
				CGI::end_html(),
			);
		}
	} else {
		if ( $self->is_ajax ) {
			return $self->to_json({error => 403});
		} else {
			return $self->authen->login_box;
		}
	}
}

######
######

sub sOper { ('eq' => '=?', 'ne' => '<>?', 'lt' => '<?', 'le' => '<=?', 'gt' => '>?', 'ge' => '>=?', 'bw' => " LIKE '?%'", 'ew' => " LIKE '%?'", 'cn' => " LIKE '%?%'") }

sub dbx { 
	my $self = shift;

	my ($sql, $attr, @bind_values) = @_;

	my @data;
	my $sth = $self->dbh->prepare($sql);
	eval { $sth->execute(@bind_values); } or $@ && Carp::croak $@;
	Carp::carp $self->dbh->errstr if $self->dbh->err;
	while ( my $row = $sth->fetchrow_hashref ) {
		# if((find_in_set('newbid',`items`.`notify`) > 0),1,NULL) `newbid`
		# if((`items`.`status` = 'Sold'),1,NULL) `sold`
		$row->{img} = (glob("pics/".$self->param('year')."/$row->{number}.*"))[0] if $row->{number};
		if ( 0 && $sql =~ / FROM /i ) {
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
			$row->{notify} = join ',', @notify;
		}
		$row->{notify} = {map { $_ => 1 } split /,/, $row->{notify}};
		push @data, {map { $_ => $row->{$_}||'' } keys %$row};
	}
	return {count=>$#data+1, records=>[@data]};
}

sub dbx_json {
	my $self = shift;
	#print STDERR Dumper({count=>$#data+1, records=>\@data});
	return $self->to_json($self->dbx(@_));
}

sub dumper {
	my $self = shift;
	$self->log->debug(join "\n", map { ref $_ ? Dumper($_) : $_ } @_) if $self->cfg('DEBUG');
}

sub _expand_group {
	my ($groups, $group) = @_;

	my %groups = %$groups;
	$group =~ s/^://;
	push @{$groups{$group}}, _expand_group(\%groups, $_) foreach grep { /^:/ } @{$groups{$group}};
	return grep { /^(?!:)/ } @{$groups{$group}};
}

1;