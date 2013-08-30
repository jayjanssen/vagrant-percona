class percona::cluster::config {

	if( $wsrep_provider_options == undef ) {
		$wsrep_provider_options = ""
	}
	if( $wsrep_slave_threads == undef ) {
		$wsrep_slave_threads = 4
	}

	file {
		"/etc/my.cnf":
			ensure  => present,
			content => template("percona/my-cluster.cnf.erb"),
			require => File["/etc/my-pxc.cnf"];
			
		"/etc/my-pxc.cnf":
			ensure => present,
			replace => false,
			content => "[mysqld]
wsrep_cluster_address = gcomm://

";
	}
}