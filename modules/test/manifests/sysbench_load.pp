class test::sysbench_load(
	$tables = 1,
	$rows = 250000,
	$threads = 1
) {
	exec { 
		'create_schema':
			command => '/usr/bin/mysqladmin create sbtest',
			cwd => '/root',
			creates => '/var/lib/mysql/sbtest/db.opt';        
		'prepare_database':
			command => "sysbench --test=sysbench_tests/db/parallel_prepare.lua --db-driver=mysql --mysql-user=root --oltp-tables-count=$tables --oltp-table-size=$rows --num-threads=$threads run",
			timeout => 0,  # unlimited
			logoutput => true,
			path => ['/usr/bin', '/bin', '/usr/local/bin'],
			cwd => '/root',
			creates => "/var/lib/mysql/sbtest/sbtest$tables.frm",
			require => Exec['create_schema'];
	}


}