include percona::repository
include percona::toolkit
include percona::server
include percona::config
include percona::service

include misc
include misc::mysql_datadir
include misc::sysbench
include misc::tpcc_mysql

Class['misc::mysql_datadir'] -> Class['percona::server']

Class['percona::repository'] -> Class['percona::server'] -> Class['percona::config'] -> Class['percona::service']

Class['percona::repository'] -> Class['percona::toolkit']
