include percona::repository
include percona::toolkit
include percona::cluster
include percona::cluster_config

include misc

Class['misc'] -> Class['percona::repository']

Class['percona::repository'] -> Class['percona::cluster_config'] -> Class['percona::cluster']
Class['percona::repository'] -> Class['percona::toolkit']
