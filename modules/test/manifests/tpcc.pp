class test::tpcc {	
	exec {
		"build-essentials":
			command => '/usr/bin/yum groupinstall "Development Tools" -y',
			cwd => "/tmp",
			unless => "/bin/rpm -q gcc";
	}
	package { 
		"openssl-devel": ensure => 'installed'; 
		"bzr": ensure => 'installed'; 
	}
	
	
	exec {
		"tpcc_checkout":
			command => "bzr branch lp:~percona-dev/perconatools/tpcc-mysql",
			cwd => "/root",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			require => Package['bzr'],
			unless => "test -d /root/tpcc-mysql";
		"tpcc_build":
			command => 'make all',
			cwd => "/root/tpcc-mysql/src",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			require => [ Package['openssl-devel'], Exec['build-essentials', 'tpcc_checkout']],
			unless => "test -f /root/tpcc-mysql/tpcc_load";
	}
}
