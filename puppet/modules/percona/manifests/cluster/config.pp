class percona::cluster::config {
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