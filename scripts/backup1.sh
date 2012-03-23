user=root
password=secret
hostname=127.0.0.1
port=3306
dbname=rra_master
path=/data/vhosts/washingtonrotary.com/dev/htdocs/rra/backups
date=`date +%Y%m%d`

mysqldump -u$user -p$password -h$hostname -P$port -f -Q -a -c --add-drop-table $dbname > "$path"/"$dbname"_data_"$date".sql
chmod 0220 "$path"/"$dbname"_data_"$date".sql
mysqldump -u$user -p$password -h$hostname -P$port -f --no-create-info --no-data --no-create-db --skip-opt $dbname > "$path"/"$dbname"_triggers_"$date".sql
chmod 0220 "$path"/"$dbname"_triggers_"$date".sql
mysqldump -u$user -p$password -h$hostname -P$port -f --routines --skip-triggers --no-create-info --no-data --no-create-db --skip-opt $dbname > "$path"/"$dbname"_routines_"$date".sql
chmod 0220 "$path"/"$dbname"_routines_"$date".sql
mysqldump -u$user -p$password -h$hostname -P$port -f --events --skip-triggers --no-create-info --no-data --no-create-db --skip-opt $dbname > "$path"/"$dbname"_events_"$date".sql
chmod 0220 "$path"/"$dbname"_events_"$date".sql
mysqldump -u$user -p$password -h$hostname -P$port -f --skip-triggers --no-data --no-create-db --skip-opt $dbname > "$path"/"$dbname"_tables_"$date".sql
chmod 0220 "$path"/"$dbname"_tables_"$date".sql

echo "Successful!"
