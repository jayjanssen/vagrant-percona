include percona::repository
include percona::toolkit
include percona::server
include percona::config

include misc

Class['percona::repository'] -> Class['percona::config'] -> Class['percona::server']
Class['percona::repository'] -> Class['percona::toolkit']
