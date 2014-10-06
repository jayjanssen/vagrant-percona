class percona::sysbench {	
	package {
		"sysbench":
			# Should be in percona yum repo now
			ensure => 'installed';
	}
	file {
		"/root/sysbench_tests":
			ensure => link,
			target => '/usr/share/doc/sysbench/tests',
			require => Package['sysbench'];
	}
}
