class percona::cluster::remove_server {
	package {
		"Percona-Server-server-55.$hardwaremodel":
			require => Yumrepo['Percona'],
			ensure => 'absent';
		"Percona-Server-client-55.$hardwaremodel":
			require => Yumrepo['Percona'],
			ensure => 'absent'; 
		"Percona-Server-shared-55.$hardwaremodel":
			require => Yumrepo['Percona'],    
			ensure => 'absent'; 
		"Percona-Server-devel-55.$hardwaremodel":
			ensure => 'absent';
	}    

	exec { 
		'remove_master_info':
			command => "rm -f /var/lib/mysql/master.info",    
			path => "/usr/bin:/usr/sbin:/bin:/sbin",
			onlyif => [
				 "test -f /var/lib/mysql/master.info"
			 ];
		'remove_sysbench':
			command => "rpm -e sysbench",
			path => "/usr/bin:/usr/sbin:/bin:/sbin",
			onlyif => [
				"rpm -q Percona-Server-server-55"
			];
	}      

	Exec['remove_sysbench'] -> Package["Percona-Server-devel-55.$hardwaremodel"] -> Package["Percona-Server-server-55.$hardwaremodel"] -> Package["Percona-Server-client-55.$hardwaremodel"] -> Package["Percona-Server-shared-55.$hardwaremodel"] -> Exec['remove_master_info']
}