class mha::node {
	exec {
		"mha4mysql-node":
			command => "/usr/bin/yum localinstall -y https://mysql-master-ha.googlecode.com/files/mha4mysql-node-0.54-0.el6.noarch.rpm",
			cwd => "/tmp",
			unless => "/bin/rpm -q mha4mysql-node",
			require => [Package['MySQL-shared-compat'], File['/tmp/sysbench.rpm']];
	}

	user {
		'mha':
			ensure => present,
			groups => ['mysql'],
			home => "/home/mha",
			managehome => true;
	}

	file {
		'/var/log/masterha':
			ensure => 'directory',
			owner => 'mha',
			group => 'mysql',
			mode => 0775;
	}
}