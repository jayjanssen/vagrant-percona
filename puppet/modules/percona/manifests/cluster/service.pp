class percona::cluster::service {
	service {
		"mysql":
			enable  => true,
			ensure  => 'running',
			require => Package['MySQL-server'],
			subscribe => File["/etc/my.cnf"];
		
	}
}