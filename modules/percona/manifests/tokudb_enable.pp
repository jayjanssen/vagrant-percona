class percona::tokudb_enable {
    exec {
        "MySQL-TokuDB-enable":
                command => "ps_tokudb_admin --enable && systemctl restart mysql.service",
                cwd => "/tmp",
                path => ['/bin','/usr/bin','/usr/local/bin'],
                creates => '/var/lib/mysql/tokudb.directory';
    }
}
