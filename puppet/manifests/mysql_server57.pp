class { 'mysql::repository':
	56_enabled => 0,
	57_enabled => 1
}

include mysql::server

Class['mysql::repository'] -> Class['mysql::server']