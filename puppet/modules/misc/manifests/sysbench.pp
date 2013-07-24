class misc::sysbench {	
	exec {
		"sysbench":
			command => "/usr/bin/yum localinstall -y /vagrant/modules/misc/files/sysbench-0.5-3.el6.i386.rpm",
			cwd => "/tmp",
			unless => "/bin/rpm -q sysbench",
			require => Package['MySQL-shared-compat'];
	}
}
