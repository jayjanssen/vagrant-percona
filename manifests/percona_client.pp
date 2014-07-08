include percona::repository
include percona::client

Class['percona::repository'] -> Class['percona::client']