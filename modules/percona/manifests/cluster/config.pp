class percona::cluster::config {

    # Use the default_interface's address unless wsrep_node_address is explicitly set
    
    if $wsrep_node_address == undef {
        if $default_interface != undef {
            $wsrep_node_address = getvar("ipaddress_${default_interface}")
        }
    }

	file {
		"/etc/my.cnf":
			ensure  => present,
			content => template("percona/my-cluster.cnf.erb");
	}
}
