class percona::tokudb_config {
	file {
		"/etc/mysql.d/my-tokudb.cnf":
			ensure  => present,
			content => template("percona/my-tokudb.cnf.erb") 
	}                     
}
