class test::sysbench_test_script {
	file {
		'/root/run_sysbench_oltp.sh':
			ensure => present,
			content => "sysbench --db-driver=mysql --test=sysbench_tests/db/oltp.lua --mysql-user=test --mysql-password=test --oltp-tables-count=$tables --oltp-table-size=$rows --num-threads=$threads --report-interval=1 --max-requests=0 --tx-rate=$tx_rate run | grep tps",
			mode => 0700;
	}
}
