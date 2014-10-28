include stdlib

class { 'consul':
	join_cluster => $join_cluster,
    config_hash => {
        'datacenter'  => $datacenter,
        'data_dir'    => '/opt/consul',
        'ui_dir'      => '/opt/consul/ui',
        'log_level'   => 'INFO',
        'node_name'   => $node_name,
        'server'      => true,
		'bind_addr'        => $bind_addr,
        'client_addr' => '0.0.0.0',
		'bootstrap_expect' => $bootstrap_expect
    }
}