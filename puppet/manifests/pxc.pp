include percona::repository
include percona::toolkit
include percona::cluster

include misc
include misc::mysql_datadir
include misc::sysbench

Class['misc'] -> Class['percona::repository']

Class['misc::mysql_datadir'] -> Class['percona::cluster']

Class['percona::repository'] -> Class['percona::cluster']
Class['percona::repository'] -> Class['percona::toolkit']
