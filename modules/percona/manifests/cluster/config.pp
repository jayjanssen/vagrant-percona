class percona::cluster::config {

	if( $wsrep_provider_options == undef ) {
		$wsrep_provider_options = ""
	}
	if( $wsrep_slave_threads == undef ) {
		$wsrep_slave_threads = 4
	}
	if( $wsrep_auto_increment_control == undef ) {
		$wsrep_auto_increment_control = ON
	}

	if( $innodb_flush_log_at_trx_commit == undef ) {
		$innodb_flush_log_at_trx_commit = '1'
	}

	if( $extra_mysqld_config == undef ) {
			$extra_mysqld_config = ''
	}

	file {
		"/etc/my.cnf":
			ensure  => present,
			content => template("percona/my-cluster.cnf.erb");
	}
}
