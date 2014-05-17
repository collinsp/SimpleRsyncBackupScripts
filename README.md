SimpleRsyncBackupScripts
========================

# add a config file
cp config.sample config
vi config

# each line in the config file is
# note ommit the destination in the rsync command
<BACKUPNAME> : rsync command here

# to start the backup, run
start_backup.pl

# each backup is a set of hardlinks
# each file that is different is rsynced into the dated backup
# to optionally deduplicate across different backups use
dedup_backups.pl

# to view your disk usage
disk_usage.pl

# to delete a backup set
rm -rf BACKUPS/backupname/20140517134528
