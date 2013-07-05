class misc {
	package {
		'screen': ensure => 'present';
		'telnet': ensure => 'present';
		'unzip': ensure => 'present';
		'lsof': ensure => 'present';
		'ntp': ensure => 'present';
		'ntpdate': ensure => 'present';
	}
	
	$ntpservice = $operatingsystem ? {
		ubuntu => "ntp",
		default => "ntpd"
	}
	service {
		$ntpservice: ensure => 'running', enable => true, require => [Package['ntp']];
	}
	
	case $operatingsystem {
		centos: {
			service {
				'iptables': ensure => 'stopped', enable => false;
			}
		}
	}
	
	exec {
			"myq_gadgets":
				command => "mkdir /root/bin 2> /dev/null; wget -O myq_gadgets-latest.tgz https://github.com/jayjanssen/myq_gadgets/tarball/master && tar xvzf myq_gadgets-latest.tgz -C /root/bin --strip-components=1",
				cwd => "/tmp",
				creates => "/root/bin/myq_status",
				path => ['/bin','/usr/bin','/usr/local/bin'];
	}
	
	exec {
			"wget http://downloads.mysql.com/docs/sakila-db.zip":
				cwd => "/root",
				creates => "/root/sakila-db.zip",
				path => ['/bin','/usr/bin','/usr/local/bin'];
	}
}

