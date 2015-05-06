class percona::tokudb {
    # Install TokuDB package
    # currently only built for PS 5.6 and x86_64
	case $operatingsystem {
		centos: {
			package {
                "Percona-Server-tokudb-$percona_server_version.$hardwaremodel":
                    alias => "MySQL-tokudb",
                    ensure => latest;
			}
		}
	}
    exec {
        "MySQL-TokuDB":
                command => "ps_tokudb_admin --enable",
                cwd => "/tmp",
                path => ['/bin','/usr/bin','/usr/local/bin'];
    }
}
