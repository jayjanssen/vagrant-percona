# Some script parameters are defined in Vagrantfile.training.rb
$sysbench_skip_test_client = true
$extra_mysqld_config = "binlog_format = ROW\nlog-slave-updates\n"

include base::packages
include base::insecure

class { 'base::swappiness': swappiness => $swappiness }

include misc::aws_cli

include training::ssh_key
include training::local_percona_training_repo
include training::my_movies
include training::training_db_data

include percona::server
include percona::config
include percona::service
include percona::toolkit

class {
	'mysql::datadir':
		datadir_dev => $datadir_dev,
		skip_mysql_install_db => true
}

# Mount the datadir, then install Percona Server, then download the data then setup my.cnf then start mysql
Class['mysql::datadir'] -> Class['percona::server'] -> Class['training::training_db_data'] -> Class['percona::config'] -> Class['percona::service']

# Must have the training repo before downloading/installing PS
Class['training::local_percona_training_repo'] -> Class['percona::server']
Class['training::local_percona_training_repo'] -> Class['percona::toolkit']

# Need to add sysbench to local training repo
#Class['training::local_percona_training_repo'] -> Class['percona::sysbench']
