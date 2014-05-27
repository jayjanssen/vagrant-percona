include percona::repository
include percona::server
include percona::config
include percona::service

include mysql::datadir

Class['mysql::datadir'] -> Class['percona::server']

Class['percona::repository'] -> Class['percona::server'] -> Class['percona::config'] -> Class['percona::service']
