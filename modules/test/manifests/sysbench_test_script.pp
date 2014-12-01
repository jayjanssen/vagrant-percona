class test::sysbench_test_script {
    if !$mysql_host { $mysql_host = 'localhost' }
    
	file {
		'/usr/local/bin/run_sysbench_oltp.sh':
			ensure => present,
			content => "sysbench --db-driver=mysql --test=/usr/share/doc/sysbench/tests/db/oltp.lua --mysql-user=test --mysql-password=test --mysql-host=$mysql_host --mysql-ignore-errors=all --oltp-tables-count=$tables --oltp-table-size=$rows --oltp-auto-inc=off --num-threads=$threads --report-interval=1 --max-requests=0 --tx-rate=$tx_rate run | grep tps",
			mode => 0755;
	}
    
	file {
		'/usr/local/bin/run_sysbench_update_index.sh':
			ensure => present,
			content => "sysbench --db-driver=mysql --test=/usr/share/doc/sysbench/tests/db/update_index.lua --mysql-user=test --mysql-password=test --mysql-host=$mysql_host --mysql-ignore-errors=all --oltp-tables-count=$tables --oltp-table-size=$rows --oltp-auto-inc=off --num-threads=$threads --report-interval=1 --max-requests=0 --tx-rate=$tx_rate run | grep tps",
			mode => 0755;
	}
    
    
	if $enable_consul == 'true' {
        # Watch for a test in consul and trigger it when the appropriate key/value is set
		consul::watch {
            'test': type => 'event', handler => 'wall test consul event';
            'sysbench_stop': type => 'event', handler => 'killall sysbench';
            'sysbench_oltp': type => 'event', handler => "pidof sysbench || /usr/local/bin/run_sysbench_oltp.sh";
            'sysbench_update_index': type => 'event', handler => "pidof sysbench || /usr/local/bin/run_sysbench_update_index.sh";
		}
        
		consul::service {
            'sysbench_running': check_script   => "killall -0 sysbench", check_interval => '10s';
            'sysbench_ready': check_script   => "which sysbench", check_interval => '1m';
	    }
    }
}
