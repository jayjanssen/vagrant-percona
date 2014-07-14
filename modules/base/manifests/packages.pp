class base::packages {
	package {
		'screen': ensure => 'present';
		'telnet': ensure => 'present';
		'unzip': ensure => 'present';
		'lsof': ensure => 'present';
		'ntp': ensure => 'present';
		'ntpdate': ensure => 'present';
		'wget': ensure => 'present';
		'sysstat': ensure => 'present';
		'bind-utils': ensure => 'present';
	}
	
	$ntpservice = $operatingsystem ? {
		ubuntu => "ntp",
		default => "ntpd"
	}
	service {
		$ntpservice: ensure => 'running', enable => true, require => [Package['ntp']];
	}
}

