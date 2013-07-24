include percona::repository
include percona::toolkit
include percona::cluster

include misc
include misc::sysbench

Class['misc'] -> Class['percona::repository']

Class['percona::repository'] -> Class['percona::cluster']
Class['percona::repository'] -> Class['percona::toolkit']
