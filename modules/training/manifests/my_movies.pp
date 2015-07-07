class training::my_movies {
	
	package {
		"httpd":
			ensure  => latest;
		"php":
			ensure  => latest;
		"php-mysql":
			ensure  => latest;
		"bzr":
			ensure  => latest;
	}
	
	service {
		"httpd":
			ensure  => running,
			require => [ Package["httpd"], Package["php"], Package["php-mysql"] ];
	}
	
	exec {
		"install-my-movies":
			command => "/usr/bin/bzr branch lp:my-movies && touch /var/www/html/my-movies.ok",
			cwd => "/var/www/html",
			creates => "/var/www/html/my-movies.ok",
			require => [ Package["httpd"], Package["bzr"] ];
	}
}
