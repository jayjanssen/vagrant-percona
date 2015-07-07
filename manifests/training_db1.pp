# script parameters
$backup_to_recover = "var_lib_mysql-20150707.xbstream"
$percona_server_version = 56

# my.cnf parameters
$server_id = 5
$innodb_buffer_pool_size = "5G"
$extra_mysqld_config = "binlog_format = ROW\nlog-slave-updates\n"

include misc::aws_cli

include training::ssh_key
include training::local_percona_training_repo
include training::my_movies
include training::training_db_data

include percona::server
include percona::config
include percona::service

# Only these need a specific order
Class['training::training_db_data'] -> Class['percona::config'] -> Class['percona::server'] -> Class['percona::service']
