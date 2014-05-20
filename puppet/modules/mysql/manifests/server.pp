class mysql::server {
	package { 
		'mysql-community-server':
			ensure => 'installed';	
		'mysql-community-libs':
			alias => "MySQL-shared",
			ensure => 'installed';
		'mysql-community-devel':
			alias => 'MySQL-devel',
			ensure => 'installed';
	}
	
}
