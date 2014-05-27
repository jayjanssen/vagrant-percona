include percona::repository
include percona::toolkit

# Include percona server because tpcc-mysql coredumps without it!
include percona::server

include misc
include misc::sysbench
include misc::tpcc_mysql

Class['misc'] -> Class['percona::repository']

Class['percona::repository'] -> Class['percona::toolkit']
Class['percona::repository'] -> Class['percona::server']

