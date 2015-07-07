class training::training_db_data {
	
	package { 'percona-xtrabackup': ensure => present }
	
	exec {
		"stop-mysql-if-installed":
			command => "service mysql stop",
			provider => "shell",
			onlyif => "test -x /etc/init.d/mysql";
		"empty-datadir":
			command => "/bin/rm -rf /var/lib/mysql/*",
			onlyif => "test -d /var/lib/mysql";
	}
	
	file {
		"/var/lib/mysql":
			ensure => "directory",
			purge => true,
			force => true,
			recurse => true,
			backup => false;
		"/tmp/$backup_to_restore": require => Exec["mysql-download-snapshot"];
		"/var/lib/mysql/xtrabackup_logfile": require => Exec["extract-backup"];
		"/var/lib/mysql/xtrabackup_binlog_info": require => Exec["apply-log"];
	}
	
	exec {
		"mysql-download-snapshot":
			command => "/usr/bin/wget -O /tmp/$backup_to_restore http://s3.amazonaws.com/percona-training/$backup_to_restore && touch /tmp/training_get_data.done",
			creates => "/tmp/training_get_data.done",
			timeout => 0,
			require => [ File["/var/lib/mysql"] ];
		"extract-backup":
			command => "/usr/bin/xbstream -x -C /var/lib/mysql/ < /tmp/$backup_to_restore && touch /tmp/training_extract.done",
			creates => "/tmp/training_extract.done",
			timeout => 0,
			require => [ File["/tmp/$backup_to_restore"], Exec["stop-mysql-if-installed"], Exec["empty-datadir"] ];
		"decompress":
			command => "/usr/bin/innobackupex --decompress /var/lib/mysql",
			onlyif => "/bin/find /var/lib/mysql/ -iname '*.qp' | /bin/grep -c .ibd.qp",
			require => [ Exec['extract-backup'] ];
		"apply-log":
			command => "/usr/bin/innobackupex --apply-log --use-memory=4G /var/lib/mysql/ 2>&1 >/tmp/apply-log.log && touch /tmp/training_apply_log.done",
			creates => "/tmp/training_apply_log.done",
			timeout => 0,
			require => [ Exec["decompress"], File["/var/lib/mysql/xtrabackup_logfile"] ];
		"chown-datadir":
			command => "/bin/chown -R mysql:mysql /var/lib/mysql && touch /tmp/chown.done",
			creates => "/tmp/training_chown.done",
			timeout => 0,
			require => [ Exec["apply-log"] ];
	}
}
