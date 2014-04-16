class mysql::repository(
	$55_enabled = 0,
	$56_enabled = 1,
	$57_enabled = 0
) {
	case $operatingsystem {
		centos: {
			package { 
				'mysql-community-release-el6-5':
				ensure => 'installed',
				require => Exec['mysql-community-release-el6-5'];
				
			}
			
			exec {  
				"mysql-community-release-el6-5":
					command => "/usr/bin/yum localinstall -y https://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm",
					cwd => "/tmp",
					unless => "/bin/rpm -q mysql-community-release-el6-5";
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
