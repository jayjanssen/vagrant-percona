include stdlib

class { 'consul':
    config_hash => {
        'datacenter'  => $datacenter,
        'data_dir'    => '/opt/consul',
        'ui_dir'      => '/opt/consul/ui',
        'client_addr' => '0.0.0.0',
        'log_level'   => 'INFO',
        'node_name'   => $node_name,
        'server'      => false,
		'join_cluster' => $join_node,
    }
}