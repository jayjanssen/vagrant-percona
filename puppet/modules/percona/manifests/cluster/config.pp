class percona::cluster::config {
	file {
		"/etc/my.cnf":
			ensure  => present,
			content => template("percona/my-cluster.cnf.erb"),
	}
}