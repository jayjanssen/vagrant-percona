class misc {
	package {
		'screen': ensure => 'present';
		'telnet': ensure => 'present';
		'unzip': ensure => 'present';
		'lsof': ensure => 'present';
		'ntp': ensure => 'present';
		'ntpdate': ensure => 'present';
		'wget': ensure => 'present';
		'sysstat': ensure => 'present';
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
			exec{ 'stop-iptables':
				command => '/etc/init.d/iptables stop',
				path => ['/bin','/usr/bin','/usr/local/bin', '/sbin'],
				onlyif => 'iptables -L -v | grep REJECT';
			}
		}
	}
	
	exec {
			"myq_gadgets":
				command => "mkdir /root/bin 2> /dev/null; wget -O myq_gadgets-latest.tgz https://github.com/jayjanssen/myq_gadgets/tarball/master && tar xvzf myq_gadgets-latest.tgz -C /root/bin --strip-components=1",
				cwd => "/tmp",
				creates => "/root/bin/myq_status",
				path => ['/bin','/usr/bin','/usr/local/bin'],
				require => Package['wget'];
	}
	
	exec {
		"disable-selinux":
			path    => ["/usr/bin","/bin"],
			command => "echo 0 >/selinux/enforce",
			unless => "grep 0 /selinux/enforce";
  }
}

