class percona::cluster::garb {
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


	# CENtoS ONLY FOR NOW
	case $operatingsystem {
		centos: {
			package {
				"Percona-XtraDB-Cluster-garbd-$galera_version":
					alias => "galera",
					ensure => "installed";
			}
		}
	}

	file {
		"/etc/sysconfig/garb":
			ensure		=> present,
			content		=> "# Copyright (C) 2012 Codership Oy
# This config file is to be sourced by garb service script.

# A space-separated list of node addresses (address[:port]) in the cluster
GALERA_NODES='$arbitrator_nodes'

# Galera cluster name, should be the same as on the rest of the nodes.
GALERA_GROUP='$arbitrator_clustername'

# Optional Galera internal options string (e.g. SSL settings)
# see http://www.codership.com/wiki/doku.php?id=galera_parameters
# GALERA_OPTIONS=''

# Log file for garbd. Optional, by default logs to syslog
# Deprecated for CentOS7, use journalctl to query the log for garbd
# LOG_FILE=''
";
	}

	service {
		"garb":
			ensure		=> running,
			require		=> [ File["/etc/sysconfig/garb"], Package["Percona-XtraDB-Cluster-garbd-$galera_version"] ];
	}
}
