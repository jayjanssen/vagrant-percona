include base::packages
include percona::repository
include percona::server
include percona::config
include percona::service
include percona::toolkit

include misc::myq_gadgets

include mysql::datadir

Class['mysql::datadir'] -> Class['percona::server']

Class['percona::repository'] -> Class['percona::server'] -> Class['percona::config'] -> Class['percona::service']
Class['percona::repository'] -> Class['percona::toolkit']

Class['base::packages'] -> Class['misc::myq_gadgets']
Class['percona::server'] -> Class['misc::myq_gadgets']
