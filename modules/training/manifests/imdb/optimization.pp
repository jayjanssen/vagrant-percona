class training::imdb::optimization {

	file {
		"/root/.data/":
			ensure => directory;
		"/root/.data/imdb_optimization.sql":
			ensure	=> present,
			source	=> "puppet:///modules/training/imdb_optimization.sql",
			require => File["/root/.data/"];
	}

}
