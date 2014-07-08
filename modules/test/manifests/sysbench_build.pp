class test::sysbench_build {	
	exec {
		"build-essentials":
			command => '/usr/bin/yum groupinstall "Development Tools" -y',
			cwd => "/tmp",
			unless => "/bin/rpm -q gcc";
	}
	package { 
		"bzr": ensure => 'installed'; 
        "libtool": ensure => 'installed';
	}
	
	
	exec {
		"sysbench_checkout":
			command => "bzr branch lp:sysbench",
			cwd => "/root",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			require => Package['bzr'],
			unless => "test -d /root/sysbench";
		"sysbench_build":
			command => '/root/sysbench/autogen.sh && /root/sysbench/configure && make && make install',
			cwd => "/root/sysbench",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			require => [ Exec['build-essentials', 'sysbench_checkout']],
			creates => "/usr/local/bin/sysbench";
	}
    
	file {
		"/root/sysbench_tests":
			ensure => link,
			target => '/root/sysbench/sysbench/tests',
			require => Exec['sysbench_build'];
	}
}
