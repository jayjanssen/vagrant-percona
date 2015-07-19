class training::training_db_data {

	if ($backup_to_restore == undef) {
		fail("You must supply a \$backup_to_restore")
	}

	package {
		'percona-xtrabackup': ensure => present;
		'qpress': ensure => present;
	}
	
	# Download the MD5 checksum for the backup. This will be used to validate
	# if the backup has been successfully downloaded and doesn't need to be redownloaded
	# on repeat provisioning
	exec { "download-backup-hash":
		command => "/usr/bin/wget -O /tmp/${backup_to_restore}.md5 http://s3.amazonaws.com/percona-training/${backup_to_restore}.md5",
		creates => "/tmp/${backup_to_restore}.md5",
		timeout => 0
	}

	exec {
		"stop-mysql-if-installed":
			command => "/usr/bin/systemctl stop mysql",
			path => "/bin:/usr/bin",
			onlyif => "/usr/bin/systemctl is-active mysql";
		"empty-datadir":
			command => "/bin/rm -rf /var/lib/mysql/*",
			path => "/bin:/usr/bin",
			onlyif => "test -d /var/lib/mysql/";
	}

	file {
		"/tmp/$backup_to_restore": require => Exec["mysql-download-snapshot"];
		"/var/lib/mysql/xtrabackup_logfile": require => Exec["extract-backup"];
		"/var/lib/mysql/xtrabackup_binlog_pos_innodb": require => Exec["apply-log"];
	}

	exec {

		"mysql-download-snapshot":
			command => "/usr/bin/wget -O /tmp/${backup_to_restore} http://s3.amazonaws.com/percona-training/${backup_to_restore}",
			unless => "/usr/bin/md5sum -c /tmp/${backup_to_restore}.md5 --status 2>/dev/null",
			timeout => 0,
			require => [ Exec["download-backup-hash"] ];

		"extract-backup":
			command => "/usr/bin/xbstream -x -C /var/lib/mysql/ < /tmp/$backup_to_restore",
			timeout => 0,
			require => [ File["/tmp/${backup_to_restore}"], Exec["stop-mysql-if-installed"], Exec["empty-datadir"] ];

		"decompress":
			command => "/usr/bin/innobackupex --decompress /var/lib/mysql",
			onlyif => "/bin/find /var/lib/mysql/ -iname '*.qp' | /bin/grep -c .ibd.qp",
			timeout => 0,
			require => [ Exec['extract-backup'] ];

		"apply-log":
			command => "/usr/bin/innobackupex --apply-log --use-memory=4G /var/lib/mysql/ 2>&1 >/tmp/apply-log.log",
			creates => "/var/lib/mysql/xtrabackup_binlog_pos_innodb",
			timeout => 0,
			require => [ Exec["decompress"], File["/var/lib/mysql/xtrabackup_logfile"] ];

		"chown-datadir":
			command => "/bin/chown -R mysql:mysql /var/lib/mysql && touch /tmp/chown.done",
			creates => "/tmp/training_chown.done",
			timeout => 0,
			require => [ Exec["apply-log"] ];
	}
}
