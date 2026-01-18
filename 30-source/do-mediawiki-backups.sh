#!/bin/sh

time=`date +%G%m%d-%H%M%S`
Sqlitebkpfile="/usr/backups/mw-sqlite-db-backup-$time.sqlite"
tarfile="mw-${time}.tgz"

echo
echo "Copying MediaWiki SqLite database . . ."
sudo docker exec mediawiki php /var/www/html/maintenance/run.php \
    SqliteMaintenance.php --backup-to  "$Sqlitebkpfile"
    #/var/www/html/maintenance/SqliteMaintenance.php --backup-to  "$Sqlitebkpfile"
echo
sudo docker cp "mediawiki:$Sqlitebkpfile" /usr/backups/mediawiki

echo
echo "Dumping MediaWiki content (full) . . ."
sudo docker exec mediawiki php /var/www/html/maintenance/run.php dumpBackup --full > "/usr/backups/mediawiki/mw-fulldump-$time.xml"

echo
echo "Copying Mediawiki config files . . ."
sudo docker cp mediawiki:/var/www/html/LocalSettings.php "/usr/backups/mediawiki/LocalSettings-$time.php"

#echo
#echo "creating $tarfile ..."
#tar -zcf $tarfile ./backups/
#echo
#echo "gzipping tar file..."
#gzip $tarfile
#echo
echo "...done."
