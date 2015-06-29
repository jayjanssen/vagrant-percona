class misc::myq_tools {
    exec {
    		"myq_tools":
    			command => "wget https://github.com/jayjanssen/myq-tools/releases/download/v0.8/myq_tools.tgz && tar xvzf myq_tools.tgz -C /usr/local/bin --strip-components=1 && ln -sf /usr/local/bin/myq_status.linux-amd64 /usr/local/bin/myq_status",
    			cwd => "/tmp",
    			creates => "/usr/local/bin/myq_status.linux-amd64",
    			path => ['/bin','/usr/bin','/usr/local/bin'],
    			require => Package['wget'];
    }
}
