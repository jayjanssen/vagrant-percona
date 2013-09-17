class mha::manager {
	exec {  
		"mha4mysql-manager":
			command => "/usr/bin/yum localinstall -y https://mysql-master-ha.googlecode.com/files/mha4mysql-manager-0.55-0.el6.noarch.rpm",
			cwd => "/tmp",
			unless => "/bin/rpm -q mha4mysql-manager",
			require => [Package['MySQL-shared-compat'], File['/tmp/sysbench.rpm']];
	}
	file {
		"/etc/mha.cnf":
		ensure => 'present',
		content => template("mha/mha.cnf.erb"),

	}
}