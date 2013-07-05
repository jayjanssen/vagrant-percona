class percona::cluster {
	case $operatingsystem {
		centos: {
			# package {
			# 	"Percona-Server-server-55.$hardwaremodel":
			# 		alias => "MySQL-server";
			# 	"Percona-Server-client-55.$hardwaremodel":
			# 		alias => "MySQL-client";
			# 	"mysql-libs":
			# 		ensure => "absent";
			# 	"Percona-Server-shared-55.$hardwaremodel":
			# 		alias => "MySQL-shared";
			# 	"Percona-Server-shared-compat":
			# 		require => [ Package['mysql-libs'], Package['MySQL-client'] ],
			# 		alias => "MySQL-shared-compat",
			# 		ensure => "installed";
			# }
		}
		ubuntu: {
			package {
				"percona-xtradb-cluster-server-5.5":
					alias => "MySQL-server";
				"percona-xtradb-cluster-client-5.5":
					alias => "MySQL-client";
			}
		}
	}	

	service {
		"mysql":
			enable  => true,
			ensure  => 'running',
			require => Package['MySQL-server'],
	}
	
	
}