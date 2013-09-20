class percona::client {
	case $operatingsystem {
		centos: {
			package {
				"Percona-Server-client-$percona_server_version.$hardwaremodel":
					alias => "MySQL-client";
				"Percona-Server-devel-$percona_server_version.$hardwaremodel":
					require => [ Package['MySQL-client'] ],
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
