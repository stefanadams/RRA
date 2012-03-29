package RRA::Manage;

use strict;
use warnings;

use base 'RRA::Base';
use SQL::Interp ':all';

sub sOper { ('eq' => '=', 'ne' => '<>', 'lt' => '<', 'le' => '<=', 'gt' => '>', 'ge' => '>=', 'bw' => " LIKE '%'", 'ew' => " LIKE '%'", 'cn' => " LIKE '%%'") }

1;
