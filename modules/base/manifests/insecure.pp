class base::insecure {

	case $operatingsystem {
		centos: {
			service {
				'iptables': ensure => 'stopped', enable => false, 
                    status => 'iptables -L -v | grep REJECT' ;
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

