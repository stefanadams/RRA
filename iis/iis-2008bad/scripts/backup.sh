#!/bin/bash

a=$(date +'%Y-%m-%d--%H-%M-%S')
/usr/bin/mysqldump -h mysql -u washingtonrotary -pharris -Q -a -c --add-drop-table washrotary > ../backups/washrotary.$a.sql
echo $a
