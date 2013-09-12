class percona::config {

	if( $server_id == undef ) {
		$server_id = 1
	}

	if( $innodb_log_file_size == undef ) {
		$innodb_log_file_size = '64M'
	}


	file {
		"/etc/my.cnf":
			ensure  => present,
			content => template("percona/my.cnf.erb"),
	}                     
}