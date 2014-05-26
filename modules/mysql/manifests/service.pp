class mysql::service {

	service {
		"mysqld":
			enable  => true,
			ensure  => 'running',
			require => [File['/etc/my.cnf']],
			subscribe => File['/etc/my.cnf'];
			
	}
}