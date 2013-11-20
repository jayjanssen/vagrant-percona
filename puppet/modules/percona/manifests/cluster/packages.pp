class percona::cluster::packages {
	# Default PS version is 55 for now
	if( $percona_server_version == undef or $percona_server_version == 55 ) {
		$percona_server_version = ''
	} elsif( $percona_server_version == 56 ) {
		$percona_server_version = '-56'
	}

	# ugly way of making sure the version we want to use doesn't conflict with the old one
	# (oh boy this whole thing might need refactoring)
	if $percona_server_version == '' {
		$other_percona_server_version="-56"
	} elsif $percona_server_version == "-56" {
		$other_percona_server_version=""
	}


	case $operatingsystem {
		centos: {
			package {
				"Percona-XtraDB-Cluster-server$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-client$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-shared$other_percona_server_version.$hardwaremodel":
					ensure => "absent";

				"Percona-XtraDB-Cluster-server$percona_server_version.$hardwaremodel":
					require => [ Yumrepo['percona'], Package['MySQL-shared-compat'] ],
					alias => "MySQL-server",
					ensure => "installed";
				"Percona-XtraDB-Cluster-client$percona_server_version.$hardwaremodel":
					require => [ Yumrepo['percona']],
					alias => "MySQL-client",
					ensure => "installed";
				"rsync":
					ensure => "present";  
				"Percona-Server-shared-compat":
					require => [ Yumrepo['percona'], Package['MySQL-client'] ],
					alias => "MySQL-shared-compat",
					ensure => "installed";
				# "mysql-libs":
				# 	ensure => "absent";
			}
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
}
