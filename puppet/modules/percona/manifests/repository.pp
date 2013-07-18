class percona::repository {

	case $operatingsystem {
		ubuntu: {
			exec { "apt-key":
				command => "apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A",
				unless => "apt-key list | grep -i percona",
				path => "/usr/bin:/bin";
			}
			
			$repo = "deb http://repo.percona.com/apt precise main
deb-src http://repo.percona.com/apt precise main
			"
			file { "/etc/apt/sources.list.d/percona-repo.list":
				content => $repo
			}
			
			exec { "percona-apt-update":
				command => "apt-get update && touch /tmp/apt-update-percona-repo",
				require => [File['/etc/apt/sources.list.d/percona-repo.list'], Exec['apt-key']],
				path => "/usr/bin:/bin",
				creates => "/tmp/apt-update-percona-repo";
			}
		}
		centos: {
			$releasever = "6"
			yumrepo {
				"percona":
				descr       => "Percona",
				enabled     => 1,
				baseurl     => "http://repo.percona.com/centos/$releasever/os/$hardwaremodel/",
				gpgcheck    => 0;
			 }
		}
	}

}
