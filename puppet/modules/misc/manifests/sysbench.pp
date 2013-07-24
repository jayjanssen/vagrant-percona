class misc::sysbench {	
	exec {
		"sysbench":
			command => "/usr/bin/yum localinstall -y /vagrant/puppet/modules/misc/files/sysbench-0.5-3.el6_.x86_64.rpm",
			cwd => "/tmp",
			unless => "/bin/rpm -q sysbench",
			require => Package['MySQL-shared-compat'];
	}
	file {
		"/root/sysbench_tests":
			ensure => link,
			target => '/usr/share/doc/sysbench/tests',
			require => Exec['sysbench'];
	}
}
