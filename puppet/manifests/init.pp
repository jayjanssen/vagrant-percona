include percona::repository
include percona::toolkit
include percona::server
include percona::config

include misc
include misc::mysql_datadir
include misc::sysbench

Class['misc::mysql_datadir'] -> Class['percona::server']


Class['percona::repository'] -> Class['percona::config'] -> Class['percona::server']
Class['percona::repository'] -> Class['percona::toolkit']
