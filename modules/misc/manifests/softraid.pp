class misc::softraid(
	$softraid_dev,
	$softraid_level,
	$softraid_devices,
	$softraid_dev_str
){

	package {
		'mdadm': ensure => 'present';
	}

	exec {
		"$softraid_dev":
			command => "mdadm --create --verbose --force --run $softraid_dev --level=$softraid_level --raid-devices=$softraid_devices $softraid_dev_str",
			require => Package['mdadm'],
			path => "/usr/sbin",
			creates => "/dev/md0";
	}
}