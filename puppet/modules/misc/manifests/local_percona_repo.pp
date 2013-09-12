class misc::local_percona_repo {	
	# Enable local percona repo in /var/repo

	case $operatingsystem {
		centos: {
			yumrepo{ 'local_percona_repo':
				name => "local",
				descr => "Local Repo",
				gpgcheck => "0",
				enabled => "1",
				baseurl => "file:///var/repo",
				priority => 1
			}
		}
	}
}