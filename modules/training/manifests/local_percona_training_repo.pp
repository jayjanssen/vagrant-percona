# Create a repo that is an S3 bucket mirror of percona.com

class training::local_percona_training_repo {
	
	case $operatingsystem {
		centos: {
			yumrepo{ 'local_percona_training_repo':
				name => "percona-training-repo",
				descr => "Local Percona Training Repo",
				gpgcheck => "0",
				enabled => "1",
				baseurl => "http://s3.amazonaws.com/percona-training/repo/",
				priority => 1
			}
		}
	}
}
