class percona::cluster::sstuser {
	include percona::toolkit

	exec {
		'create_sst_user':
			command => "mysql -e \"GRANT LOCK TABLES, RELOAD, REPLICATION CLIENT ON *.* TO 'sst'@'localhost' IDENTIFIED BY 'secret'\"",
			cwd => '/root',
			unless => "pt-show-grants | grep \"GRANT LOCK TABLES, RELOAD, REPLICATION CLIENT ON *.* TO 'sst'@'localhost'\"",
			path => ['/usr/bin', '/bin'],
			require => [ Package['percona-toolkit'], Service['mysql'] ];
	}
}