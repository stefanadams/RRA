package CGI::Application::Loaded;

use vars '$VERSION';
$VERSION = '0.01';

use strict;
use warnings;

use base 'CGI::Application';
use Apache2::RequestIO ();
use CGI::Application::Plugin::Authentication;
use CGI::Application::Plugin::Authorization;
use CGI::Application::Plugin::ConfigAuto qw/cfg cfg_file/;
use CGI::Application::Plugin::ErrorPage 'error';
use CGI::Application::Plugin::FillInForm 'fill_form';
use CGI::Application::Plugin::ValidateRM; 
use CGI::Application::Plugin::AutoRunmode;
use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::Forward;
use CGI::Application::Plugin::Session;	# Server side
use CGI::Application::Plugin::Cookie;	# Client side
use CGI::Application::Plugin::DBH qw/dbh_config dbh/;
use CGI::Application::Plugin::AnyTemplate;
use CGI::Application::Plugin::DetectAjax;
use CGI::Application::Plugin::JSON ':all';
use CGI::Application::Plugin::RequireAjax 'requires_ajax';
use CGI::Application::Plugin::RequireSSL 'mode_redirect';
use CGI::Application::Plugin::Stream 'stream_file';
use CGI::Application::Plugin::Request;
use CGI::Application::Plugin::SiteStatus;
use CGI::Application::Plugin::Rotate;
use CGI::Application::Plugin::About;
use CGI::Application::Plugin::Data;
use CGI::Application::Plugin::SQLInterp;
use CGI::Application::Plugin::WriteExcel;
use CGI::Application::Plugin::LogDispatch;

# For development, need to activated with an ENV variable. 
use CGI::Application::Plugin::DebugScreen;
use CGI::Application::Plugin::DevPopup;
use CGI::Application::Standard::Config;

1;
