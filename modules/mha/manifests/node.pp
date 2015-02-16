class mha::node {
	exec {
		"mha4mysql-node":
			command => "/usr/bin/yum localinstall -y https://72003f4c60f5cc941cd1c7d448fc3c99e0aebaa8.googledrive.com/host/0B1lu97m8-haWeHdGWXp0YVVUSlk/mha4mysql-node-0.56-0.el6.noarch.rpm",
			cwd => "/tmp",
			unless => "/bin/rpm -q mha4mysql-node";
	}

	user {
		'mha':
			ensure => present,
			groups => ['mysql'],
			home => "/home/mha",
			managehome => true;
	}
	
	file {
		'/etc/sudoers.d/mha_sudo':
			ensure => present,
			content => 'Cmnd_Alias VIP_MGMT = /sbin/ip

mha     ALL=(root)      NOPASSWD: VIP_MGMT
';
	}

	file {
		'/var/log/masterha':
			ensure => 'directory',
			owner => 'mha',
			group => 'mysql',
			mode => 0775;
	}

	file {
		'/home/mha/.ssh':
			ensure => 'directory',
			owner => 'mha',
			group => 'mysql',
			mode => 0700,
			require => User['mha'];
		'/home/mha/.ssh/id_dsa':
			ensure => 'present',
			owner => 'mha',
			group => 'mha',
			mode => 0400,
			content => '-----BEGIN DSA PRIVATE KEY-----
MIIBuwIBAAKBgQDL+aCXasdNotUQBd31nBnhzUscLdKuRc2iZpTK/XixMd3PJXlC
wyhfioz7iwf14QHOr2qg6ZkA14nvwqjLVXzF6NqAH4InCbZ1yC2u4DyrEkHozhVC
td+JN5AkioAuojZPUGQAYkCYFKzvDkBoxudQ5jE6IgI3+4Ihi4D2kbyN0wIVAIGm
73q7GGXuHtCwO6P+sQLI5ntLAoGBAIahKvuV95ZFEPjGkoRqgIsqpjq2+bx63v0z
UIyxA3shkCnd70QaujvLeRG6zYVIgaWyfzA1JN2r3mTSgBfAMnNqTdkJiTBkbbH3
RC7ML2Ap3OpBdlYweAT1ABQDKHv7ryD8mkAlPE50afhdokElYTrViwyK3icfkoC+
gsy6n90wAoGADDBl8zD9UiJuFpFQgmMXKbZ5ttBpwx1A6UKeHZ0ipB77gFWpmEie
J0FRnJtmMiNYp4SXbSfF1ERyGcfs5FxOOp+qxLUFGI/rSYe5QOVNwtnpUvdX9c7B
B/SxVLJUbxpi3TWwbCFwKS3d/FxCmg9/Wkv1MFA4+qUWC2s693j/wKECFFYJrWUb
ZlY7oK+DFJqr1jZNE5QA
-----END DSA PRIVATE KEY-----
',
			require => File['/home/mha/.ssh'];
	}
	ssh_authorized_key {
		'mha-ssh-key':
			ensure => 'present',
			key => 'AAAAB3NzaC1kc3MAAACBAMv5oJdqx02i1RAF3fWcGeHNSxwt0q5FzaJmlMr9eLEx3c8leULDKF+KjPuLB/XhAc6vaqDpmQDXie/CqMtVfMXo2oAfgicJtnXILa7gPKsSQejOFUK134k3kCSKgC6iNk9QZABiQJgUrO8OQGjG51DmMToiAjf7giGLgPaRvI3TAAAAFQCBpu96uxhl7h7QsDuj/rECyOZ7SwAAAIEAhqEq+5X3lkUQ+MaShGqAiyqmOrb5vHre/TNQjLEDeyGQKd3vRBq6O8t5EbrNhUiBpbJ/MDUk3aveZNKAF8Ayc2pN2QmJMGRtsfdELswvYCnc6kF2VjB4BPUAFAMoe/uvIPyaQCU8TnRp+F2iQSVhOtWLDIreJx+SgL6CzLqf3TAAAACADDBl8zD9UiJuFpFQgmMXKbZ5ttBpwx1A6UKeHZ0ipB77gFWpmEieJ0FRnJtmMiNYp4SXbSfF1ERyGcfs5FxOOp+qxLUFGI/rSYe5QOVNwtnpUvdX9c7BB/SxVLJUbxpi3TWwbCFwKS3d/FxCmg9/Wkv1MFA4+qUWC2s693j/wKE=',
			type => 'ssh-dss',
			user => 'mha';
	}
  
	exec {
		'create_mha_user_all':
			command => "mysql -e \"GRANT ALL ON *.* TO 'mha'@'%' IDENTIFIED BY 'mha'\"",
			cwd => '/root',
			unless => "pt-show-grants | grep \"GRANT ALL PRIVILEGES ON *.* TO 'mha'@'%'\"",
			path => ['/usr/bin', '/bin'],
			require => [ Package['percona-toolkit'], Service['mysql'] ];
		'create_mha_user_localhost':
			command => "mysql -e \"GRANT ALL ON *.* TO 'mha'@'localhost' IDENTIFIED BY 'mha'\"",
			cwd => '/root',
			unless => "pt-show-grants | grep \"GRANT ALL PRIVILEGES ON *.* TO 'mha'@'localhost'\"",
			path => ['/usr/bin', '/bin'],
			require => [ Package['percona-toolkit'], Service['mysql'] ];
	}
}
