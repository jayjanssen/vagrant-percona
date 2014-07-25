include percona::repository

include percona::cluster::client
include percona::cluster::server
include percona::cluster::config
include percona::cluster::service


include mysql::datadir

Class['mysql::datadir'] -> Class['percona::cluster::server']

Class['percona::repository'] -> Class['percona::cluster::client'] -> Class['percona::cluster::server'] -> Class['percona::cluster::config'] -> Class['percona::cluster::service']
