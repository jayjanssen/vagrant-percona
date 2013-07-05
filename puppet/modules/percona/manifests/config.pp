class percona::config {
	file {
		"/etc/my.cnf":
			ensure  => present,
			content => template("percona/my.cnf.erb"),
	}             
	
	file {
		"/mnt/data":
			ensure => directory,
			mode => 0755,
			require => Exec['rebuild-xvdb'];
	}         
}