# 5.6 enabled by default.  Client is reponsible to only have one of these 
# enabled and to disable the default.
if( $enable_55 == undef ) {
	$enable_55 = 0
}
if( $enable_56 == undef ) {
	$enable_56 = 1
}
if( $enable_57 == undef ) {
	$enable_57 = 0
}


class { 'mysql::repository':
	55_enabled => $enable_55,
	56_enabled => $enable_56,
	57_enabled => $enable_57
}

include misc::mysql_datadir
include mysql::server
include mysql::config
include mysql::service

Class['misc::mysql_datadir'] -> Class['mysql::server']
Class['mysql::repository'] -> Class['mysql::server'] -> Class['mysql::config'] -> Class['mysql::service']
