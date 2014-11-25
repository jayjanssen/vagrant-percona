include base::packages
include base::insecure
include stdlib


$config_hash = delete_undef_values( {
        'datacenter'  => $datacenter,
        'data_dir'    => '/opt/consul',
        'log_level'   => 'INFO',
        'node_name'   => $node_name,
		'bind_addr'   => $default_interface ? {
                undef => undef,
                default => getvar("ipaddress_${default_interface}")
            },
        'client_addr' => '0.0.0.0',
        'ui_dir'      => '/opt/consul/ui',
        'server'      => true,
		'bootstrap_expect' => $bootstrap_expect,
})

class { 'consul':
	join_cluster => $join_cluster,
    config_hash => $config_hash
}

Class['base::insecure'] -> Class['consul']