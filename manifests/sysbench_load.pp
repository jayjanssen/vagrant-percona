class { 'test::sysbench_load':
	tables => $tables,
	rows => $rows,
	threads => $threads,
	schema => $schema
}
