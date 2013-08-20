include percona::repository
include percona::toolkit
include percona::server
include percona::config

include misc
include misc::sysbench


Class['percona::repository'] -> Class['percona::config'] -> Class['percona::server']
Class['percona::repository'] -> Class['percona::toolkit']
