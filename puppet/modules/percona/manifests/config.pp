class percona::config {

	if( $server_id == undef ) {
		$server_id = 1
	}

	if( $innodb_buffer_pool_size == undef ) {
		$innodb_buffer_pool_size = '128M'
	}

	if( $innodb_log_file_size == undef ) {
		$innodb_log_file_size = '64M'
	}

	if( $extra_mysqld_config == undef ) {
		$extra_mysqld_config = ''
	}


	file {
		"/etc/my.cnf":
			ensure  => present,
			content => template("percona/my.cnf.erb"),
	}                     
}