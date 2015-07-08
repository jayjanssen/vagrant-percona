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

class {
	'mysql::datadir':
		datadir_dev => $datadir_dev,
		skip_mysql_install_db => true
}

# Mount the datadir XFS before downloading the backup
Class['mysql::datadir'] -> Class['training::training_db_data']

# Download backup before starting mysql
Class['training::training_db_data'] -> Class['percona::server']

# my.cnf exists before starting mysql
Class['percona::config'] -> Class['percona::server']