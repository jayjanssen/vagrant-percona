class percona::cluster::clustercheckuser {
	include percona::toolkit

	exec {
		'create_clustercheck_user':
			command => "mysql -e \"GRANT USAGE ON *.* TO 'clustercheckuser'@'localhost' IDENTIFIED BY 'clustercheckpassword!'\"",
			cwd => '/root',
			unless => "pt-show-grants | grep \"GRANT USAGE ON *.* TO 'clustercheckuser'@'localhost'\"",
			path => ['/usr/bin', '/bin'],
			require => [ Package['percona-toolkit'], Service['mysql'] ];
	}
}