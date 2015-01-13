class test::sysbench_pkg {	
	# this was used for a custom built sysbench (which is in ../files).
	# now the percona repo comes with the sysbench package
	# exec {
	# 	"sysbench":
	# 	command => "/usr/bin/yum localinstall -y /tmp/sysbench.rpm",
	# 	cwd => "/tmp",
	# 	unless => "/bin/rpm -q sysbench",
	# 		require => [File['/tmp/sysbench.rpm']];
	# 	}
	# 	file {
	# 		"/tmp/sysbench.rpm":
	# 		source => "puppet:///modules/test/sysbench-0.5-4.el6_.x86_64.rpm",
	# 	ensure => present;
	# 		"/root/sysbench_tests":
	# 	ensure => link,
	# 		target => '/usr/share/doc/sysbench/tests',
	# 		require => Exec['sysbench'];
	# 	}

	package {
		"sysbench":
			ensure => latest;
	}	
}
