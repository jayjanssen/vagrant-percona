include percona::repository
include percona::cluster::client

Class['percona::repository'] -> Class['percona::cluster::client']
