class percona::server {
	case $operatingsystem {
		centos: {
			package {
				"Percona-Server-server-55.$hardwaremodel":
					alias => "MySQL-server";
				"Percona-Server-client-55.$hardwaremodel":
					alias => "MySQL-client";
				# "mysql-libs":
				# 	ensure => "absent";
				"Percona-Server-shared-55.$hardwaremodel":
					alias => "MySQL-shared";
				"Percona-Server-shared-compat":
					require => [ Package['MySQL-client'] ],
					alias => "MySQL-shared-compat",
					ensure => "installed";
			}
		}
		ubuntu: {
			package {
				"percona-server-server":
					alias => "MySQL-server";
				"percona-server-client":
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
