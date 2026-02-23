#!/bin/bash


trap 'exit 1' INT

echo "=============================================="
echo "Backing up Mediawiki content and configuration"
echo "=============================================="
echo 

BACKUPLOC="/usr/backups/mediawiki/"

time=`date +%G%m%d-%H%M%S`

# tarfile in the host filesystem
tarfile="/usr/backups/kamrui-mediawiki-${time}.tgz"

# sqlite backup file in the container
Sqlitebkpfile="/usr/backups/mw-sqlite-db-backup-$time.sqlite"


echo
echo "Removing old backup files . . ."
rm -if  ${BACKUPLOC}*

echo
echo "Copying MediaWiki SqLite database from container . . ."
sudo docker exec mediawiki php /var/www/html/maintenance/run.php \
    SqliteMaintenance.php --backup-to  "$Sqlitebkpfile"
echo
sudo docker cp "mediawiki:$Sqlitebkpfile" "$BACKUPLOC"

echo
echo "Dumping MediaWiki content (full) . . ."
sudo docker exec mediawiki php /var/www/html/maintenance/run.php dumpBackup --full > "${BACKUPLOC}mw-fulldump-$time.xml"

echo
echo "Copying Mediawiki config files from container . . ."
sudo docker cp mediawiki:/var/www/html/LocalSettings.php "${BACKUPLOC}LocalSettings-$time.php"

echo
echo "creating tarfile $tarfile in host filesystem ... "
tar -zcf $tarfile ${BACKUPLOC}*
echo


echo "Transferring tgz file to NAS"
# ding
scp "$tarfile" sshd@192.168.1.157:/shares/Public/backups/

echo
echo "...done."
