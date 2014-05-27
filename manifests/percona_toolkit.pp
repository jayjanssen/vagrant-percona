include percona::repository
include percona::toolkit

Class['percona::repository'] -> Class['percona::toolkit']
