class haproxy::server {

	package { 
		'haproxy':
			ensure => 'installed';	
	}

	service {
		'haproxy':
			ensure => 'running',
			enable => true,
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
			content => template('haproxy/haproxy.cfg.erb');
	}

}

