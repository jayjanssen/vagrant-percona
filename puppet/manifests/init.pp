include percona::repository
include percona::toolkit
include percona::server
include misc

Class['percona::repository'] -> Class['percona::server']
Class['percona::repository'] -> Class['percona::toolkit']
