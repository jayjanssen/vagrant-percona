class mha::manager {
	exec {  
		"mha4mysql-manager":
			command => "/usr/bin/yum localinstall -y https://mysql-master-ha.googlecode.com/files/mha4mysql-manager-0.55-0.el6.noarch.rpm",
			cwd => "/tmp",
			unless => "/bin/rpm -q mha4mysql-manager",
			require => [Package['MySQL-shared-compat'], File['/tmp/sysbench.rpm']];
	}
	
	if( $master_ip_failover_script == undef ) {
		$master_ip_failover_script = "/usr/local/bin/master_ip_failover"
	}
	
	if( $master_ip_online_change_script == undef ) {
		$master_ip_online_change_script = "/usr/local/bin/master_ip_online_change_script"
	}
	
	file {
		"/etc/mha.cnf":
			ensure => 'present',
			content => template("mha/mha.cnf.erb");
		"/usr/local/bin/master_ip_failover":
			ensure => 'present',
			source => 'puppet:///modules/mha/master_ip_failover';
		"/usr/local/bin/master_ip_online_change_script":
			ensure => 'present',
			source => 'puppet:///modules/mha/master_ip_online_change';
	}
}