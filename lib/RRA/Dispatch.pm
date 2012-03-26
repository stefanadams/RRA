#<VirtualHost *:80>
#        ServerName dev.washingtonrotary.com
#
#        # Find static files like css, js, images, and html here
#        DocumentRoot /data/vhosts/washingtonrotary.com/dev/htdocs
#        <Directory /data/vhosts/washingtonrotary.com/dev/htdocs>
#                Options Indexes Includes ExecCGI FollowSymLinks
#                AllowOverride All
#                Allow from all
#        </Directory>
#
#        RewriteEngine on
#        RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-f
#        RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-d
#        RewriteRule ^/rra/(.*)\.html$ /rra/pl/template/$1 [L,PT]
#        PerlOptions +Parent
#        PerlSwitches -I/data/vhosts/washingtonrotary.com/dev/lib
#
#        # Applications
#        PerlModule RRA::API
#        PerlModule RRA::API::Donors
#        PerlModule RRA::Template
#        <Location /rra/pl>
#                SetEnv CONFIG /data/vhosts/washingtonrotary.com/dev/config/rra.cfg
#                SetHandler perl-script
#                PerlHandler RRA::Dispatch
#        </Location>
#</VirtualHost>

package RRA::Dispatch;
use base 'CGI::Application::Dispatch';
use RRA::Dispatch;
use RRA::Template;
use RRA::Backup;
use RRA::XLS;
use RRA::Bookmarks;
use RRA::API;
use RRA::BuildSelect;
use RRA::AutoComplete;
use RRA::Manage;
use RRA::Manage::Donors;
use RRA::Manage::Items;
use RRA::Manage::Items::Sequence;
use RRA::Manage::Stockitems;
use RRA::Manage::Bellitems;
use RRA::Manage::Ads;
use RRA::Manage::Ads::Ad;
use RRA::Manage::Ads::Schedule;
use RRA::Manage::Rotarians;
use RRA::Manage::Bidding;
use RRA::Manage::Bidders;
use RRA::Manage::Winners;

use Config::Auto;
my $config = Config::Auto::parse($ENV{CONFIG});

#print STDERR '[dispatch] '.(join "\n", map { "\t$_:\t$ENV{$_}" } sort keys %ENV)."\n".(join "\n", map { "\t$_:\t$config->{$_}" } sort keys %{$config});

sub dispatch_args {{
	prefix => 'RRA',
	debug => 0,
	auto_rest => 1,
	table => [
		'manage/rotarians'			=> { app => 'Manage::Rotarians', rm => 'rotarians' },
		'manage/rotarians/:rm'			=> { app => 'Manage::Rotarians' },
		'manage/bidding'			=> { app => 'Manage::Bidding', rm => 'bidding' },
		'manage/bidding/item/:item_id'		=> { app => 'Manage::Bidding', rm => 'item' },
		'manage/bidding/:rm'			=> { app => 'Manage::Bidding' },
		'manage/bidders'			=> { app => 'Manage::Bidders', rm => 'bidders' },
		'manage/bidders/:rm'			=> { app => 'Manage::Bidders' },
		'manage/donors'				=> { app => 'Manage::Donors', rm => 'donors' },
		'manage/donors/donor/:donor_id'		=> { app => 'Manage::Donors', rm => 'donor' },
		'manage/donors/:rm'			=> { app => 'Manage::Donors' },
		'manage/items'				=> { app => 'Manage::Items', rm => 'items' },
		'manage/items/sequence/:n?'		=> { app => 'Manage::Items::Sequence', rm => 'sequence' },
		'manage/items/:rm'			=> { app => 'Manage::Items' },
		'manage/winners'			=> { app => 'Manage::Winners', rm => 'winners' },
		'manage/winners/:rm'			=> { app => 'Manage::Winners' },
		'manage/stockitems'			=> { app => 'Manage::Stockitems', rm => 'stockitems' },
		'manage/stockitems/:rm'			=> { app => 'Manage::Stockitems' },
		'manage/bellitems'			=> { app => 'Manage::Bellitems', rm => 'bellitems' },
		'manage/bellitems/:rm'			=> { app => 'Manage::Bellitems' },
		'manage/ads'				=> { app => 'Manage::Ads', rm => 'ads' },
		#'manage/ads/ad/:ad_id?'		=> { app => 'Manage::Ads::Ad', rm => 'ad' },
		'manage/ads/schedule/:n?'		=> { app => 'Manage::Ads::Schedule', rm => 'schedule' },
		'manage/ads/:rm'			=> { app => 'Manage::Ads' },
		'manage/:rm/*'				=> { app => 'Manage' },
		'api/header'				=> { app => 'API', rm => 'header' },
		'api/ad/:ad_id'				=> { app => 'API', rm => 'ad' },
		'api/alert/:alert?'			=> { app => 'API', rm => 'alert' },
		'api/bidding'				=> { app => 'API', rm => 'bidding' },
		'api/:rm'				=> { app => 'API' },
		'api/:rm/*'				=> { app => 'API' },
		'xls/:rm'				=> { app => 'XLS' },
		'bs/*'					=> { app => 'BuildSelect', rm => 'bs' },
		'ac/*'					=> { app => 'AutoComplete', rm => 'ac' },
		'login'					=> { app => 'Base', rm => 'login' },
		'logout'				=> { app => 'Base', rm => 'logout' },
		'about/:about?'				=> { app => 'Base', rm => 'about' },
		'bookmarks'				=> { app => 'Bookmarks', rm => 'bookmarks' },
		'tooltip/:item_id'			=> { app => 'Tooltip', rm => 'tooltip' },
		'backup'				=> { app => 'Backup', rm => 'backup' },
		'template/*'				=> { app => 'Template', rm => 'template' },
	],
	args_to_new => {
		TMPL_PATH => $config->{TEMPLATES},
		PARAMS => { },
	},
}}

1;
