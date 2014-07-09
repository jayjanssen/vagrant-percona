class test::sysbench_custom_lua {	

	file {
		"/root/sysbench_custom_lua":
			ensure => directory;
		"/root/sysbench_custom_lua/custom-oltp.lua":
			ensure => present,
			source => "puppet:///modules/test/sysbench_custom_lua/custom-oltp.lua",
			require => File["/root/sysbench_custom_lua"];
		"/root/sysbench_custom_lua/custom-common.lua":
			ensure => present,
			source => "puppet:///modules/test/sysbench_custom_lua/custom-common.lua",
			require => File["/root/sysbench_custom_lua"];			
	}


	package { 
		"lua-posix": ensure => 'installed'; 
	}
}
