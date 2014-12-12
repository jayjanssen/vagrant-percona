class base::insecure {

	case $operatingsystem {
		centos: {
			if( $operatingsystemrelease =~ /^7/ ) {
				service {
					'firewalld': ensure => 'stopped', enable => false;
				}
			} else {
				service {
					'iptables': ensure => 'stopped', enable => false, 
	                    status => 'iptables -L -v | grep REJECT' ;
				}
			}
		}
	}
	
	exec {
		"disable-selinux":
			path    => ["/usr/sbin","/bin","/usr/bin"],
			command => "setenforce Permissive",
			unless => "getenforce | grep Permissive";
	}

}

