# 5.6 enabled by default.  Client is reponsible to only have one of these 
# enabled and to disable the default.
if( $enable_55 == undef ) {
	$enable_55 = 0
}
if( $enable_56 == undef ) {
	$enable_56 = 1
}
if( $enable_57 == undef ) {
	$enable_57 = 0
}


class { 'mysql::repository':
	55_enabled => $enable_55,
	56_enabled => $enable_56,
	57_enabled => $enable_57
}


include base::packages
include base::insecure

include misc::mysql_datadir
include mysql::server
include mysql::config
include mysql::service

include percona::repository
include percona::sysbench

include test::imdb
include test::user
include test::sysbench_test_script


Class['misc::mysql_datadir'] -> Class['mysql::server']
Class['mysql::repository'] -> Class['mysql::server'] -> Class['mysql::config'] -> Class['mysql::service']


Class['mysql::service'] -> Class['test::imdb']


Class['base::packages'] -> Class['percona::repository']
Class['base::insecure'] -> Class['percona::repository']

Class['percona::repository'] -> Class['percona::sysbench']



class { 'test::sysbench_load':
	tables => $tables,
	rows => $rows,
	threads => $threads
}

Class['percona::sysbench'] -> Class['test::sysbench_load']
Class['mysql::service'] -> Class['test::user']
Class['test::user'] -> Class['test::sysbench_load']