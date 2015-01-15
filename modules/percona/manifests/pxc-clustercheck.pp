# This is an rpm generated from https://github.com/grypyrg/clustercheck/tree/centos7
# it has a better name, init script and rpm spec.

class percona::pxc-clustercheck {	

	if( $operatingsystem == 'centos' and $operatingsystemrelease =~ /^7/ ) {  #7.0.1406
		exec {
			"percona-clustercheck":
				command => "/usr/bin/yum localinstall -y /tmp/percona-clustercheck.rpm",
				cwd => "/tmp",
				unless => "/bin/rpm -q percona-clustercheck",
				require => [ File['/tmp/percona-clustercheck.rpm'], Package["MySQL-python"], Package["python-twisted-web"] ];
		}
		file {
			"/tmp/percona-clustercheck.rpm":
				source => "puppet:///modules/percona/percona-clustercheck-1.0-2.noarch.rpm",
				ensure => present;
		}
		service {
			"percona-clustercheck":
				ensure => running,
				subscribe => Exec['percona-clustercheck'];
		}

		package {
			"MySQL-python":
				ensure => installed;
			"python-twisted-web":
				ensure => installed
		}
	} else {
		exec {
			"percona-clustercheck":
				command => "/usr/bin/yum localinstall -y /tmp/percona-clustercheck.rpm",
				cwd => "/tmp",
				unless => "/bin/rpm -q percona-clustercheck",
				require => [File['/tmp/percona-clustercheck.rpm']];
		}
		file {
			"/tmp/percona-clustercheck.rpm":
				source => "puppet:///modules/percona/percona-clustercheck-1.0-0.noarch.rpm",
				ensure => present;
		}
		service {
			"percona-clustercheck":
				ensure => running,
				subscribe => Exec['percona-clustercheck'];
		}
	}
}