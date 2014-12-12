
class percona::agent {

	exec {
		"install_percona_agent":
			command	=> "/usr/bin/curl -s https://cloud.percona.com/install | bash /dev/stdin -api-key='$percona_agent_api_key'",
            creates => '/usr/local/percona/percona-agent/init.d/percona-agent';
        "start_percona_agent":
            command => "/usr/local/percona/percona-agent/init.d/percona-agent start",
            require => Exec['install_percona_agent'],
            unless => "/usr/local/percona/percona-agent/init.d/percona-agent status";
	}
    

}