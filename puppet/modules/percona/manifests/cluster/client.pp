class percona::cluster::client {
	case $operatingsystem {
		centos: {
			package {
				"Percona-XtraDB-Cluster-client-55.$hardwaremodel":
					alias => "MySQL-client";
				"Percona-XtraDB-Cluster-devel-55.$hardwaremodel":
					alias => "MySQL-devel";
				"Percona-XtraDB-Cluster-shared-55.$hardwaremodel":
					alias => "MySQL-shared";
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
