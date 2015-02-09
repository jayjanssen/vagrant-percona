class base::swappiness( $swappiness = 1) {
	exec{ 
		'swappiness_sysctl_conf':
			command => "echo 'vm.swappiness = $swappiness' >> /etc/sysctl.conf",
			cwd => '/root',
			unless => "grep '^vm.swappiness = $swappiness' /etc/sysctl.conf",
			path => ['/usr/bin', '/bin'];
    'apply_sysctl':
      command => "sysctl -p",
			path => ['/usr/sbin', '/usr/bin'],
      unless => "sysctl vm.swappiness | grep '^vm.swappiness = $swappiness$'";
  }
}

