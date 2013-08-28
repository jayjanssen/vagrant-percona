class percona::server {
	case $operatingsystem {
		centos: {
			package {
				"Percona-Server-server-55.$hardwaremodel":
					alias => "MySQL-server";
				# "mysql-libs":
				# 	ensure => "absent";
				"Percona-Server-shared-55.$hardwaremodel":
					alias => "MySQL-shared";
			}
		}
		ubuntu: {
			package {
				"percona-server-server":
					alias => "MySQL-server";
			}
		}
	}	
}
