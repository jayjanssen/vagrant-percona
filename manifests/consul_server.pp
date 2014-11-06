include stdlib

class { 'consul':
	join_cluster => $join_cluster,
    config_hash => {
        'datacenter'  => $datacenter,
        'data_dir'    => '/opt/consul',
        'log_level'   => 'INFO',
        'node_name'   => $node_name,
		'bind_addr'   => $bind_addr,
        'client_addr' => '0.0.0.0',
        'ui_dir'      => '/opt/consul/ui',
        'server'      => true,
		'bootstrap_expect' => $bootstrap_expect,
    }
}