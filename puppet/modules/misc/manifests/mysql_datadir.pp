class misc::mysql_datadir {	

	package {
		'xfsprogs': ensure => 'present';
	}

	exec {
		"mkfs_mysql_datadir":
			command => "mkfs.xfs -f /dev/xvdf",
			require => Package['xfsprogs'],
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
",
			unless => "mount | grep xvdf";
		"mkdir_mysql_datadir":
			command => "mkdir /var/lib/mysql",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
",
			unless => "test -d /var/lib/mysql";

	}


	mount {
		"/var/lib/mysql":
			ensure => "mounted",
			device => "/dev/xvdf",
			fstype => "xfs",
			options => "noatime",
			atboot => "true",
			require => Exec["mkfs_mysql_datadir", "mkdir_mysql_datadir"];

	}

	# recreate the mysql datadir if it doesn't exist but mysql_install_db is present
	# If mysql hasn't been installed yet, this will not run and let the package install create the datadir
	exec {
		"mysql_install_db":
			command => "mysql_install_db --user=mysql --datadir=/var/lib/mysql",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
",
			require => Mount["/var/lib/mysql"],
			onlyif => "which mysql_install_db && test ! -f /var/lib/mysql/mysql/user.frm";
	}

	# IO scheduler
	exec {
		"xvdf_noop":
			command => "echo 'noop' > /sys/block/xvdf/queue/scheduler",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "grep '\\[noop\\]' /sys/block/xvdf/queue/scheduler";
	}

	# mount


}