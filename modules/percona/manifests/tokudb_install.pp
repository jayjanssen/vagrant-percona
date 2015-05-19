class percona::tokudb_install {
    # Install TokuDB package
    # currently only built for PS 5.6 and x86_64
	case $operatingsystem {
		centos: {
			package {
                "Percona-Server-tokudb-$percona_server_version.$hardwaremodel":
                    alias => "MySQL-TokuDB",
                    ensure => latest;
			}
		}
	}
}
