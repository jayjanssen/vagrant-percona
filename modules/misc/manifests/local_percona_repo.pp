class misc::local_percona_repo {	
	# Enable local percona repo in /var/repo
	
	file {
		'/var/repo':
			ensure => 'directory';
	}
	
	if( $operatingsystem == 'centos' and $operatingsystemrelease =~ /^7/ ) { 
		# Download only seems to be built-in to yum in 7+
		package {
			'yum': ensure => 'installed', alias => 'yum-plugin-downloadonly';
		}
	} else {
		package {
			'yum-plugin-downloadonly': ensure => 'installed';
		}
	}
	
	package {
		'createrepo': ensure => 'installed';
		'yum-plugin-priorities': ensure => 'installed';
	}
	
	exec {
		'download_pkgs': 
			command => "/usr/bin/yum install --downloadonly --downloaddir=/var/repo -y Percona-XtraDB-Cluster-56; 
/usr/bin/yum install --downloadonly --downloaddir=/var/repo -y Percona-Server-server-56;
/usr/bin/yum install --downloadonly --downloaddir=/var/repo -y percona-xtrabackup;
/usr/bin/yum install --downloadonly --downloaddir=/var/repo -y percona-nagios-plugins;
/usr/bin/yum install --downloadonly --downloaddir=/var/repo -y Percona-Server-shared-51;
/usr/bin/yum install --downloadonly --downloaddir=/var/repo -y haproxy xinetd keepalived;
touch /tmp/repo_downloaded",
			creates => "/tmp/repo_downloaded",
			require => [File['/var/repo'], Package['yum-plugin-downloadonly']];		
	}
	
	exec {
		'create_local_repo':
			command => "createrepo /var/repo",
			path => ['/bin','/usr/bin','/usr/local/bin'],
			creates => "/var/repo/repodata/repomd.xml",
			require => [Package['createrepo'], Exec['download_pkgs']],
			
	}

	case $operatingsystem {
		centos: {
			yumrepo{ 'local_percona_repo':
				name => "local",
				descr => "Local Repo",
				gpgcheck => "0",
				enabled => "1",
				baseurl => "file:///var/repo",
				priority => 1,
				require => [Exec['create_local_repo'], Package['yum-plugin-priorities']];
			}
		}
	}
}