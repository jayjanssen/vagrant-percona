class percona::cluster::sst_config {
	
	exec { 'xtrabackup_sst_grant_node1':
    command => "/usr/bin/mysql -u root -e \"GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sst'@'localhost' IDENTIFIED BY 'secret'\"",  
		path => "/usr/bin:/usr/sbin:/bin:/sbin",
    unless => "/usr/bin/mysql -u root -e\"SELECT User from mysql.user WHERE User='sst';\" | /bin/grep -q sst",
		require => Service['mysql'];
	}

}
