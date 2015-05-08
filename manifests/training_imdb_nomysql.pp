

include test::imdb
include test::imdb_ignore_indexes
include training::imdb_workload

include misc::mysql_datadir
include misc::innotop

include percona::repository


include percona::server
include percona::config
include percona::service

include training::imdb_erase_perconaserverinstall

Class['test::imdb_ignore_indexes'] -> Class['test::imdb']

Class['misc::mysql_datadir'] -> Class['percona::repository'] -> Class['percona::server'] -> Class['percona::config'] -> Class['percona::service'] -> Class['test::imdb'] 

Class['percona::server'] -> Class['misc::innotop'] -> Class ['test::imdb']


Class['test::imdb'] -> Class['training::imdb_workload'] -> Class['training::imdb_erase_perconaserverinstall']


