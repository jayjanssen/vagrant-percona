class misc::employees {
	exec {
    "download_employees":
			command => "wget -O /root/employees_db-full.tar.bz https://launchpad.net/test-db/employees-db-1/1.0.6/+download/employees_db-full-1.0.6.tar.bz2",
			cwd => "/root",
			creates => "/root/employees_db-full.tar.bz",
			path => ['/bin','/usr/bin','/usr/local/bin'],
			require => Package['wget'];
    "unpack_employees":
			command => "tar xvjf employees_db-full.tar.bz",
			cwd => "/root",
			creates => "/root/employees_db/README",
			path => ['/bin','/usr/bin','/usr/local/bin'],
			require => Exec['download_employees'];
    "load_employees":
			command => "mysql < employees.sql",
			cwd => "/root/employees_db",
			creates => "/var/lib/mysql/employees/db.opt",
			path => ['/bin','/usr/bin','/usr/local/bin'],
			require => Exec['unpack_employees'];
	}
    
    
    
    
}
