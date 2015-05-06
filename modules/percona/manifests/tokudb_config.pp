class percona::tokudb_config {
		$extra_mysqld_config = '!include /etc/my-tokudb.cnf'

	file {
		"/etc/my-tokudb.cnf":
			ensure  => present,
			content => template("percona/my-tokudb.cnf.erb"),
	}                     
}
