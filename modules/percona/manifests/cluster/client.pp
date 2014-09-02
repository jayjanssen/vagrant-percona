class percona::cluster::client {
	# Default PS version is 55 for now
	if( $percona_server_version == undef or $percona_server_version == 55 ) {
		$percona_server_version = '-55'
	} elsif( $percona_server_version == 56 ) {
		$percona_server_version = '-56'
	}

	# ugly way of making sure the version we want to use doesn't conflict with the old one
	# (oh boy this whole thing might need refactoring)
	if $percona_server_version == '' {
		$other_percona_server_version="-56"
	} elsif $percona_server_version == "-56" {
		$other_percona_server_version="-55"
	}

    
	case $operatingsystem {
		centos: {
			package {
				"Percona-XtraDB-Cluster-client$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-shared$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-devel$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
                    
				"Percona-XtraDB-Cluster-client$percona_server_version.$hardwaremodel":
					require => [ Yumrepo['Percona']],
					alias => "MySQL-client",
					ensure => "installed";
				"Percona-XtraDB-Cluster-shared$percona_server_version.$hardwaremodel":
					require => [ Yumrepo['Percona'], Package['mysql-libs']],
					alias => "MySQL-shared",
					ensure => "installed";
				"Percona-XtraDB-Cluster-devel$percona_server_version.$hardwaremodel":
					require => [ Yumrepo['Percona']],
					alias => "MySQL-devel",
					ensure => "installed";
				"Percona-Server-shared-51":
					alias => "mysql-libs",
					ensure => "present";
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
