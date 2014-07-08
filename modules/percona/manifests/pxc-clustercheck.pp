# This is an rpm generated from https://github.com/redsox38/clustercheck/tree/redsox38
# it has a better name, init script and rpm spec.

class percona::pxc-clustercheck {	
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