class { 'mysql::repository':
	56_enabled => 0,
	57_enabled => 1
}

include mysql::server
include misc::sysbench
include misc::mysql_datadir
include percona::toolkit
include percona::repository
include percona::config
include mysql::service
include misc::tpcc_mysql
include misc

Class['mysql::repository'] -> Class['mysql::server']
Class['misc::mysql_datadir'] -> Class['mysql::server']
Class['percona::repository'] -> Class['percona::toolkit']

Class['percona::repository'] -> Class['mysql::server'] -> Class['percona::config'] -> Class['mysql::service']