class percona::service {

	service {
		"mysql":
			enable  => true,
			ensure  => 'running',
			require => [File['/etc/my.cnf'],Package['MySQL-server']],
			subscribe => File['/etc/my.cnf'];
			
	}
}