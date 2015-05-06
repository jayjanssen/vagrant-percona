class percona::tokudb_enable {
    exec {
        "MySQL-TokuDB-enable":
                command => "systemctl restart mysql.service && ps_tokudb_admin --enable",
                cwd => "/tmp",
                path => ['/bin','/usr/bin','/usr/local/bin'];
    }
}
