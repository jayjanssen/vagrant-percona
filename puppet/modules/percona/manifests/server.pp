class percona::server {

	case $operatingsystem {
		centos: {
			package {
				"Percona-Server-server-$percona_server_version.$hardwaremodel":
					alias => "MySQL-server",
					ensure => latest;
				# "mysql-libs":
				# 	ensure => "absent";
				"Percona-Server-shared-$percona_server_version.$hardwaremodel":
					alias => "MySQL-shared",
					ensure => latest;
			}
		}
		ubuntu: {
			package {
				"percona-server-server":
					name => $percona_server_version ? {
						'55' => "percona-server-server-5.5",
						'56' => "percona-server-server-5.6"
					},
					alias => "MySQL-server",
					ensure => latest;
			}
		}
	}	
}
