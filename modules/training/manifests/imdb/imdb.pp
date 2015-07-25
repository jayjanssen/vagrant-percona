# This class only installs the IMDB database
# You will need training::my_movies class to get the PHP application

class training::imdb::imdb {
    
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
            command => "/usr/bin/wget -O /tmp/imdb.sql.bz2 https://s3.amazonaws.com/imdb-db-sql/imdb.sql.bz2 && touch /tmp/imdb.sql.bz2.downloaded",
            timeout => 0,
            creates => "/tmp/imdb.sql.bz2.downloaded";
        "mysql-indexes-add":
            command => "/usr/bin/mysql -u root imdb < /tmp/my.indexes.sql && touch /tmp/my.indexes.sql.done",
            creates => "/tmp/my.indexes.sql.done",
            timeout => 0,
            require => [ File["/tmp/my.indexes.sql"], Exec["mysql-imdb-import"] ];
        "mysql-grants-apply":
            command => "/usr/bin/mysql -u root < /tmp/my.grants.sql && touch /tmp/my.grants.sql.done",
            creates => "/tmp/my.grants.sql.done",
            require => [ File["/tmp/my.grants.sql"] ];
        "mysql-imdb-import":
            command => "/usr/bin/bzcat /tmp/imdb.sql.bz2 | mysql -u root imdb && touch /tmp/imdb.sql.bz2.imported",
            creates => "/tmp/imdb.sql.bz2.imported",
            timeout => 0,
            require => [ Exec['mysql-create-schema'], File["/tmp/imdb.sql.bz2"] ];
        "mysql-create-schema":
            command => "/usr/bin/mysqladmin -u root create imdb",
            creates => "/var/lib/mysql/imdb";

    }
}
