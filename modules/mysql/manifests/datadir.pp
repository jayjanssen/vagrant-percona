class mysql::datadir {	

	# Need to set $datadir_dev from Vagrantfile for this to work right
	package {
		'xfsprogs': ensure => 'present';
	}

	exec {
		"mkfs_mysql_datadir":
			command => "mkfs.xfs -f /dev/$datadir_dev",
			require => Package['xfsprogs'],
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
",
			unless => "mount | grep '/var/lib/mysql'";
		"mkdir_mysql_datadir":
			command => "mkdir /var/lib/mysql",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
",
			unless => "test -d /var/lib/mysql";

	}


	mount {
		"/var/lib/mysql":
			ensure => "mounted",
			device => "/dev/$datadir_dev",
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
		"datadir_dev_noop":
			command => "echo 'noop' > /sys/block/$datadir_dev/queue/scheduler",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "grep -E '\\[noop\\]|none' /sys/block/$datadir_dev/queue/scheduler";
	}

	# mount


}
