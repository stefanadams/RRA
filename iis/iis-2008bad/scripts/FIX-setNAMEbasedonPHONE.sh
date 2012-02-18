#!/bin/sh

[ -z "$2" ] && { echo Usage: $0 phone name; exit; }
echo "select * from bidders where phone like '%$1';" | mysql -h mysql -u washingtonrotary -pharris washrotary
echo "update bidders set name='$2' where phone like '%$1';" | mysql -h mysql -u washingtonrotary -pharris washrotary
echo "select * from bidders where phone like '%$1';" | mysql -h mysql -u washingtonrotary -pharris washrotary
