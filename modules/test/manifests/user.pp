class test::user {
	include percona::toolkit
	
	exec{ 
		'create_test_global_user':
			command => "mysql -e \"GRANT ALL PRIVILEGES ON *.* TO 'test'@'%' IDENTIFIED BY 'test'\"",
			cwd => '/root',
			unless => "pt-show-grants | grep \"GRANT ALL PRIVILEGES ON *.* TO 'test'@'%'\"",
			path => ['/usr/bin', '/bin'],
			require => [ Package['percona-toolkit'] ];
		'create_test_localhost_user':
			command => "mysql -e \"GRANT ALL PRIVILEGES ON *.* TO 'test'@'localhost' IDENTIFIED BY 'test'\"",
			cwd => '/root',
			unless => "pt-show-grants | grep \"GRANT ALL PRIVILEGES ON *.* TO 'test'@'localhost'\"",
			path => ['/usr/bin', '/bin'],
			require => [ Package['percona-toolkit'] ];
	}
}