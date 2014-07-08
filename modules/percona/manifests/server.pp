class percona::server {
	# Default PS version is 55 for now
	if( $percona_server_version == undef ) {
		$percona_server_version = '55'
	}
	
	# ugly way of making sure the version we want to use doesn't conflict with the old one
	# (oh boy this whole thing might need refactoring)
	if $percona_server_version == 55 {
		$other_percona_server_version="56"
	} elsif $percona_server_version == 56 {
		$other_percona_server_version="55"
	}

	case $operatingsystem {
		centos: {
			package {
				"Percona-Server-client-$percona_server_version.$hardwaremodel":
					alias => "MySQL-client",
					ensure => latest;
				"Percona-Server-client-$other_percona_server_version.$hardwaremodel":
					before => Package["Percona-Server-client-$percona_server_version.$hardwaremodel"],
					require => Package["Percona-Server-server-$other_percona_server_version.$hardwaremodel"],
					ensure => absent;
				"Percona-Server-server-$percona_server_version.$hardwaremodel":
					alias => "MySQL-server",
					require => Package["MySQL-client"],
					ensure => latest;
				"Percona-Server-server-$other_percona_server_version.$hardwaremodel":
					before => Package["Percona-Server-server-$percona_server_version.$hardwaremodel"],
					ensure => absent;
				"Percona-Server-shared-$percona_server_version.$hardwaremodel":
					alias => "MySQL-shared",
					ensure => latest;
				"Percona-Server-shared-$other_percona_server_version.$hardwaremodel":
					ensure => absent;
			}
		}
		ubuntu: {
			package {
				"percona-server-client":
					alias => "MySQL-client";
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
