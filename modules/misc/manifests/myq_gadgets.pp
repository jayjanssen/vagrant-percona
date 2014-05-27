class misc::myq_gadgets {
    exec {
    		"myq_gadgets":
    			command => "wget -O myq_gadgets-latest.tgz https://github.com/jayjanssen/myq_gadgets/tarball/master && tar xvzf myq_gadgets-latest.tgz -C /usr/local/bin --strip-components=1",
    			cwd => "/tmp",
    			creates => "/usr/local/bin/myq_status",
    			path => ['/bin','/usr/bin','/usr/local/bin'],
    			require => Package['wget'];
    }
}