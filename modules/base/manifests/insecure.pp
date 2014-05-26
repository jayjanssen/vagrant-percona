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
			path    => ["/usr/bin","/bin"],
			command => "echo 0 >/selinux/enforce",
			unless => "grep 0 /selinux/enforce";
  }
}

