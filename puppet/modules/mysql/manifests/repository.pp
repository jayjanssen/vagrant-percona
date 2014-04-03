class mysql::repository(
	$55_enabled = '0',
	$56_enabled = '1',
	$57_enabled = '0'

) {
	case $operatingsystem {
		centos: {
			package { 
				'mysql-community-release-el6-5':
				source => 'https://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm',
				ensure => 'installed';
			}
			
			yumrepo {
				'mysql55-community':
					enabled => $55_enabled,
					require => Package['mysql-community-release-el6-5'];
				'mysql56-community':
					enabled => $56_enabled,
					require => Package['mysql-community-release-el6-5'];
				'mysql57-community-dmr':
					enabled => $57_enabled,
					require => Package['mysql-community-release-el6-5'];
			}
		}
	}

}
