include training::imdb::imdb
include training::imdb::imdb_ignore_indexes
include training::imdb::workload

include misc::mysql_datadir
include misc::innotop

include percona::repository

include training::imdb::optimization

include percona::server
include percona::config
include percona::service

include training::erase_perconaserverinstall

Class['training::imdb::imdb_ignore_indexes'] -> Class['training::imdb::imdb']

Class['misc::mysql_datadir'] -> Class['percona::repository'] -> Class['percona::server'] -> Class['percona::config'] -> Class['percona::service'] -> Class['training::imdb::imdb'] 

Class['percona::server'] -> Class['misc::innotop'] -> Class ['test::imdb::imdb']


Class['training::imdb::imdb'] -> Class['training::imdb::workload'] -> Class['training::erase_perconaserverinstall']


