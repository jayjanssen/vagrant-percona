include percona::repository
include misc::local_percona_repo

Class['percona::repository'] -> Class['misc::local_percona_repo'] 