include percona::repository
include percona::toolkit
include percona::client

# Include percona server because tpcc-mysql coredumps without it!
include percona::server

include misc
include misc::sysbench
include misc::tpcc_mysql

include mha::manager
include mha::node

Class['misc'] -> Class['percona::repository']

Class['percona::repository'] -> Class['percona::toolkit']
Class['percona::repository'] -> Class['percona::client']
Class['percona::repository'] -> Class['percona::server']

Class['percona::server'] -> Class['mha::node']

Class['mha::node'] -> Class['mha::manager']