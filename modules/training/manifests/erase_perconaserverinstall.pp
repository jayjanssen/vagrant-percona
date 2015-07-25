# handsondba training requires imdb data, but part of the training is also to install percona server, so we have to delete it

class training::erase_perconaserverinstall {


	exec{
		"remove-percona-server":
			command	=> "/usr/bin/yum remove -y Percona-Server-server-56 Percona-Server-client-56";
	}


}
