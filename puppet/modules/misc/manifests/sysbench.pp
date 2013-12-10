class misc::sysbench {	
	exec {
		"sysbench":
			command => "/usr/bin/yum localinstall -y /tmp/sysbench.rpm",
			cwd => "/tmp",
			unless => "/bin/rpm -q sysbench",
			require => [Package['MySQL-shared'], File['/tmp/sysbench.rpm']];
	}
	file {
		"/tmp/sysbench.rpm":
			source => "puppet:///modules/misc/sysbench-0.5-3.el6_.x86_64.rpm",
			ensure => present;
		"/root/sysbench_tests":
			ensure => link,
			target => '/usr/share/doc/sysbench/tests',
			require => Exec['sysbench'];
	}
}
