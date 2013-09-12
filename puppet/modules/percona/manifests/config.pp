class percona::config {

	if( $server_id == undef ) {
		$server_id = 1
	}

	file {
		"/etc/my.cnf":
			ensure  => present,
			content => template("percona/my.cnf.erb"),
	}                     
}