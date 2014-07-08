class haproxy::server {

	package { 
		'haproxy':
			ensure => 'installed';	
	}

	service {
		'haproxy':
			ensure => 'running',
			subscribe => File["/etc/haproxy/haproxy.cfg"]
			;
	}
	


}

class haproxy::server-pxc {

	include haproxy::server
	include percona::pxc-clustercheck

	file {
		'/etc/haproxy/haproxy.cfg':
			ensure => 'present',
			require => Package['haproxy'],
			source => 'puppet:///modules/haproxy/haproxy.cfg';
	}

}

