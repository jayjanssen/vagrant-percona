class base::hostname {
	exec {
		"set_hostname":
			command => "hostname $vagrant_hostname",
			unless => "test `hostname` = $vagrant_hostname",
			path => ["/bin", "/usr/bin"];
	}
}
