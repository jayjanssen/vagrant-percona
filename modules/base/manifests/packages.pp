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
		'bzip2': ensure => 'present';
		'nano': ensure => 'present';
	}
	
	if( $operatingsystem == 'centos' and $operatingsystemrelease =~ /^7/ ) {  #7.0.1406
		package {
			'psmisc': ensure => 'present';
		}
	}
	
	$ntpservice = $operatingsystem ? {
		ubuntu => "ntp",
		default => "ntpd"
	}
	service {
		$ntpservice: ensure => 'running', enable => true, require => [Package['ntp']];
	}
}

