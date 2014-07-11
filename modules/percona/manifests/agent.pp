
class percona::agent {


	$percona_agent_version="1.0.4"

	exec {
		"download_percona_agent":
			command	=> "/usr/bin/wget \"http://www.percona.com/redir/downloads/percona-agent/$percona_agent_version/percona-agent-$percona_agent_version-$architecture.tar.gz\"",
			cwd		=> "/root",
			creates	=> "/root/percona-agent-$percona_agent_version-$architecture.tar.gz"
	}

	exec {
		"extract_percona_agent":
			command	=> "/bin/tar -xzvf percona-agent-$percona_agent_version-$architecture.tar.gz",
			cwd		=> "/root",
			creates	=> "/root/percona-agent-$percona_agent_version-$architecture",
			require => Exec['download_percona_agent']	
	}

	file {
		"/root/percona-agent-install.expect":
			ensure	=> present,
			mode    => "0755",
			source	=> "puppet:///modules/percona/percona-agent-install.expect"
	}

	exec {
		"install_percona_agent":
			command => "/root/percona-agent-install.expect $percona_agent_api_key",
			cwd		=> "/root/percona-agent-$percona_agent_version-$architecture",
			creates => "/usr/local/percona/percona-agent/config/agent.conf",
			path	=> "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			require	=> [ Package["expect"], File["/root/percona-agent-install.expect"], Service["mysql"] ];
	}

	service {
		"percona-agent":
			ensure 	=> "running",
			enable	=> true,
			require => Exec["install_percona_agent"];
	}

	package {
		"expect":
			ensure	=> installed;
	}
}