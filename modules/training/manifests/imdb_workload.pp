class training::imdb_workload {

	file {
		"/root/.bin/":
			ensure => directory;
		"/root/.bin/constant_workload.py":
			ensure	=> present,
			require => File["/root/.bin/"], 
			mode	=> 0777,
			source	=> "puppet:///modules/training/imdb_workload/constant_workload.py"; 
		"/root/add_load.py":
			ensure	=> present,
			mode	=> 0777,
			source	=> "puppet:///modules/training/imdb_workload/add_load.py"; 
		"/etc/rc.local":
			ensure	=> present,
			mode	=> 0777,
			source	=> "puppet:///modules/training/imdb_workload/rc.local";
	}

	package {"mysql-utilities": ensure=> installed;}

	exec {
		"constant_workload":
			require	=> [ Package["mysql-utilities"], Exec["create_mysql_user"] ],
			command	=> "/usr/bin/nohup /root/.bin/constant_workload.py >/dev/null 2>&1 &";
		"create_mysql_user":
			command => "/usr/bin/mysql -e \"grant all privileges on *.* to 'plmce'@'localhost' identified by 'BelgianBeers'\";";
	}

}
