class mysql::datadir (
    $datadir_dev, 
    $datadir_dev_scheduler = 'noop', 
    $datadir_fs = 'xfs', 
    $datadir_fs_opts = 'noatime',
    $datadir_mkfs_opts = '-f'
) {
	# Need to set $datadir_dev from Vagrantfile for this to work right

	package {
    	'xfsprogs': ensure => 'present';
	}
	exec {
		"mkfs_mysql_datadir":
			command => "mkfs.$datadir_fs $datadir_mkfs_opts /dev/$datadir_dev",
			require => Package['xfsprogs'],
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "mount | grep '/var/lib/mysql'";
	}
	mount {
		"/var/lib/mysql":
			ensure => "mounted",
			device => "/dev/$datadir_dev",
			fstype => $datadir_fs,
			options => $datadir_fs_opts,
			atboot => "true",
			require => Exec["mkfs_mysql_datadir", "mkdir_mysql_datadir"];

	}
	# IO scheduler
	exec {
		"datadir_dev_scheduler":
			command => "echo '$datadir_dev_scheduler' > /sys/block/$datadir_dev/queue/scheduler",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "grep -E '\\[$datadir_dev_scheduler\\]|none' /sys/block/$datadir_dev/queue/scheduler";
	}
    
    exec {
		"mkdir_mysql_datadir":
			command => "mkdir /var/lib/mysql",
			path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
			unless => "test -d /var/lib/mysql";

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



	# mount


}
