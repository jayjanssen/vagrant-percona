class percona::cluster::server {
	# Default PS version is 56
	if( $percona_server_version == undef or $percona_server_version == 56 ) {
		$percona_server_version = '-56'
	} elsif( $percona_server_version == 55 ) {
		$percona_server_version = '-55'
	}

	# ugly way of making sure the version we want to use doesn't conflict with the old one
	# (oh boy this whole thing might need refactoring)
	if $percona_server_version == '' {
		$other_percona_server_version="-55"
	} elsif $percona_server_version == "-55" {
		$other_percona_server_version="-56"
	}
	
	# You can set the $galera_version to 2 or 3 for either 55 or 56, but if it is not set it defaults like this:
	if( $galera_version == undef ) {
		if( $percona_server_version == "-55" ) {
			$galera_version = '2'
		} elsif( $percona_server_version == "-56" ) {
			$galera_version = '3'
		}
	}
	
	if( $galera_version == '2' ) {
		$other_galera_version = '3'
	} elsif( $galera_version == '3' ) {
		$other_galera_version = '2'
	}


	case $operatingsystem {
		centos: {
			package {
				"Percona-XtraDB-Cluster-server$other_percona_server_version.$hardwaremodel":
					ensure => "absent";
				"Percona-XtraDB-Cluster-galera-$other_galera_version":
					ensure => "absent";
				"Percona-XtraDB-Cluster-server$percona_server_version.$hardwaremodel":
					require => [ Yumrepo['Percona'], Package['galera'], Package["MySQL-shared"] ],
					alias => "MySQL-server",
					ensure => "installed";
				"Percona-XtraDB-Cluster-galera-$galera_version":
					alias => "galera",
					ensure => "installed";
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
	
	
	if $enable_consul == 'true' {
		consul::service {'pxc':
			port           => 3306,
			check_script   => '/usr/bin/clustercheck || (exit 2)',
			check_interval => '5s'
		}
	}
}
