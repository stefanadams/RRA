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

print STDERR '[dispatch] '.join "\n", map { "$_\t$ENV{$_}" } sort keys %ENV;

sub dispatch_args {{
	prefix => 'RRA',
	debug => 1,
	auto_rest => 1,
	table => [
		'api/rotarians'			=> { app => 'API::Rotarians', rm => 'rotarians' },
		'api/rotarians/:rm'		=> { app => 'API::Rotarians' },
		'api/bidders'			=> { app => 'API::Bidders', rm => 'bidders' },
		'api/bidders/:rm'		=> { app => 'API::Bidders' },
		'api/donors'			=> { app => 'API::Donors', rm => 'donors' },
		'api/donors/:rm'		=> { app => 'API::Donors' },
		'api/items'			=> { app => 'API::Items', rm => 'items' },
		'api/items/sequence'		=> { app => 'API::Items::Sequence', rm => 'sequence' },
		'api/items/sequence/*'		=> { app => 'API::Items::Sequence', rm => 'sequence' },
		'api/items/:rm'			=> { app => 'API::Items' },
		'api/winners'			=> { app => 'API::Winners', rm => 'winners' },
		'api/stockitems'		=> { app => 'API::Stockitems', rm => 'stockitems' },
		'api/stockitems/:rm'		=> { app => 'API::Stockitems' },
		'api/bellitems'			=> { app => 'API::Bellitems', rm => 'bellitems' },
		'api/bellitems/:rm'		=> { app => 'API::Bellitems' },
		'api/ads'			=> { app => 'API::Ads', rm => 'ads' },
		'api/ads/ad'			=> { app => 'API::Ads::Ad', rm => 'ad' },
		'api/ads/ad/:ad_id'		=> { app => 'API::Ads::Ad', rm => 'ad' },
		'api/ads/schedule'		=> { app => 'API::Ads::Schedule', rm => 'schedule' },
		'api/ads/schedule/*'		=> { app => 'API::Ads::Schedule', rm => 'schedule' },
		'api/ads/:rm'			=> { app => 'API::Ads' },
		'api/:rm/*'			=> { app => 'API' },
		'xls/:rm'			=> { app => 'XLS' },
		'login'				=> { app => 'Base', rm => 'login' },
		'logout'			=> { app => 'Base', rm => 'logout' },
		'env'				=> { app => 'Base', rm => 'env' },
		'bookmarks'			=> { app => 'Bookmarks', rm => 'bookmarks' },
		'backup'			=> { app => 'Backup', rm => 'backup' },
		'template/*'			=> { app => 'Template', rm => 'template' },
	],
	args_to_new => {
		PARAMS => { },
	},
}}

1;
