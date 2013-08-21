include percona::repository
include percona::toolkit
include percona::client

include misc
include misc::sysbench
include misc::tpcc_mysql

Class['misc'] -> Class['percona::repository']

Class['percona::repository'] -> Class['percona::toolkit']
Class['percona::repository'] -> Class['percona::client']
