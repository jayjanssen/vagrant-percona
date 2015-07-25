class test::imdb::imdb_ignore_indexes {

	file {
		'/tmp/my.indexes.sql.done':
			ensure => present
	}

}
