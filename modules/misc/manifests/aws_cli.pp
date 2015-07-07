class misc::aws_cli {
	
	exec {
		'retrieve-pip':
			command => '/bin/wget -O /root/get-pip.py https://bootstrap.pypa.io/get-pip.py',
			notify  => Exec['install-pip'],
			creates => '/root/get-pip.py';
		'install-pip':
			command => 'python get-pip.py',
			path => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
			cwd => '/root',
			require => Exec['retrieve-pip'],
			subscribe => Exec['retrieve-pip'],
			unless => 'which pip';
		'pip install awscli':
			command => 'pip install awscli',
			path => [ '/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
			unless => 'which aws',
			require => Exec['install-pip'],
			user => 'root',
			timeout => '0';
	}
}
