#!/bin/sh

[ -z "$1" ] && { echo Usage: $0 name; exit; }
echo "select * from bidders where name like '%$1%';" | mysql -h mysql -u washingtonrotary -pharris washrotary
