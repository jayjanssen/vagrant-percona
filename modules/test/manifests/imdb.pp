class test::imdb {
    
    # DB Stuff
    file {
        "/tmp/my.grants.sql":
			source => "puppet:///modules/test/imdb/my.grants.sql";
        "/tmp/my.indexes.sql":
			source => "puppet:///modules/test/imdb/my.indexes.sql";
        "/tmp/imdb.sql.bz2":
            require => Exec["mysql-download-imdb"];
    }

    exec {
        "mysql-download-imdb":
            command => "/usr/bin/wget http://krib.be/~gryp/percona/imdb.sql.bz2 && touch imdb.sql.bz2.downloaded",
            timeout => 0,
            creates => "/tmp/imdb.sql.bz2.downloaded",
            cwd => "/tmp";
        "mysql-indexes-add":
            command => "/usr/bin/mysql -u root imdb < /tmp/my.indexes.sql && touch /tmp/my.indexes.sql.done",
            creates => "/tmp/my.indexes.sql.done",
            timeout => 0,
            require => [ File["/tmp/my.indexes.sql"], Service["mysql"], Exec["mysql-imdb-import"] ];
        "mysql-grants-apply":
            command => "/usr/bin/mysql -u root < /tmp/my.grants.sql && touch /tmp/my.grants.sql.done",
            creates => "/tmp/my.grants.sql.done",
            require => [ File["/tmp/my.grants.sql"], Service["mysql"] ];
        "mysql-imdb-import":
            command => "/usr/bin/bzcat /tmp/imdb.sql.bz2 | mysql -u root imdb && touch /tmp/imdb.sql.bz2.imported",
            creates => "/tmp/imdb.sql.bz2.imported",
            timeout => 0,
            require => [ Exec['mysql-create-schema'], File["/tmp/imdb.sql.bz2"], Service["mysql"] ];
        "my-movies-get-branch":
            command => "/usr/bin/bzr branch lp:my-movies && touch /tmp/my-movies.downloaded",
            cwd => "/tmp",
            creates => "/tmp/my-movies.downloaded",
            require => [ Package["bzr"], Service["mysql"] ];
        "mysql-create-schema":
            command => "/usr/bin/mysqladmin -u root create imdb",
            creates => "/var/lib/mysql/imdb";

    }
    
    
    # App stuff
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
