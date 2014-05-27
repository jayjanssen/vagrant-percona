class mysql::client {
	package { 
		'mysql-community-client':
			ensure => 'installed';	
		'mysql-community-libs':
			alias => "MySQL-shared",
			ensure => 'installed';
		'mysql-community-devel':
			alias => 'MySQL-devel',
			ensure => 'installed';
	}
	
}
