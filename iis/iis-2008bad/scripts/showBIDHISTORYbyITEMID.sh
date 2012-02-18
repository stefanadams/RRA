#!/bin/sh

[ -z "$1" ] && { echo Usage: $0 id; exit; }
echo "select * from bidhistory where itemid='$1';" | mysql -h mysql -u washingtonrotary -pharris washrotary
