class percona::client {
	case $operatingsystem {
		centos: {
			package {
				"Percona-Server-client-55.$hardwaremodel":
					alias => "MySQL-client";
				"Percona-Server-devel-55.$hardwaremodel":
					alias => "MySQL-devel";
				"Percona-Server-shared-compat":
					require => [ Package['MySQL-client'] ],
					alias => "MySQL-shared-compat",
					ensure => "installed";
			}
		}
		ubuntu: {
			package {
				"percona-server-client":
					alias => "MySQL-client";
			}
		}
	}	
}