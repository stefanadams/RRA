#!/bin/bash

note=$1
[ -z "$note" ] && { echo -n "Enter a note about this backup: "; read note; }
[ -z "$note" ] && { echo "You didn't enter a note."; exit; }

. $(dirname $0)/../.mysql
a=$(date +'%Y-%m-%d--%H-%M-%S')

/usr/bin/mysqldump -h $DBHOST -u $DBUSER -p$DBPASS -Q -a -c --add-drop-table washrotary > $HTDOCS/backups/washrotary.$a.$note.sql
/usr/bin/mysqldump -h $DBHOST -u $DBUSER -p$DBPASS -Q -a -c --add-drop-table washrotary_2010 > $HTDOCS/backups/washrotary_2010.$a.$note.sql
/usr/bin/mysqldump -h $DBHOST -u $DBUSER -p$DBPASS -Q -a -c --add-drop-table washrotary_2011 > $HTDOCS/backups/washrotary_2011.$a.$note.sql
/usr/bin/mysqldump -h $DBHOST -u $DBUSER -p$DBPASS -Q -a -c --add-drop-table washrotary_2012 > $HTDOCS/backups/washrotary_2012.$a.$note.sql
#/usr/bin/mysqldump -h $DBHOST -u $DBROOTUSER -p$DBROOTPASS -Q -a -c --add-drop-table washingtonrotary_master > $HTDOCS/backups/washingtonrotary_master.$a.sql
#/usr/bin/mysqldump -h $DBHOST -u $DBROOTUSER -p$DBROOTPASS -Q -a -c --add-drop-table rra > $HTDOCS/backups/rra.$a.sql

#tar cvzf $HTDOCS/backups/washrotary.$a.$note.tar.gz -C $HTDOCS auction mod_perl $HTDOCS/backups/*.$a.sql
#scp $HTDOCS/backups/washrotary.$a.$note.tar.gz cogent@stefan.cog-ent.com:/tmp
echo $a
