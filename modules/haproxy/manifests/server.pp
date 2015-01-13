class haproxy::server {
	package { 
		'haproxy':
			ensure => 'installed';	
	}

	service {
		'haproxy':
			ensure => 'running';
	}

	file {
		'/etc/haproxy/haproxy.conf':
			ensure => 'present';
	}
	
}
