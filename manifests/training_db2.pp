# This manifest simply sets up a blank instance ready for students to install Percona Server,
# create a backup from a master and start this as a slave

# Some script parameters are defined in Vagrantfile.training.rb
$sysbench_skip_test_client = true
$extra_mysqld_config = "binlog_format = ROW\nlog-slave-updates\n"

include base::packages
include base::insecure

class { 'base::swappiness': swappiness => $swappiness }

include misc::aws_cli

include training::ssh_key
include training::local_percona_training_repo

include percona::config

class {
	'mysql::datadir':
		datadir_dev => $datadir_dev,
		skip_mysql_install_db => true
}