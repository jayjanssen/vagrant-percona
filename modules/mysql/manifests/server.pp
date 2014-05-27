class mysql::server {
	package { 
		'mysql-community-server':
			ensure => 'installed';	
	}
	
}
