Class['mysql::datadir'] -> Class['percona::server']

Class['percona::repository'] -> Class['percona::toolkit']

Class['base::packages'] -> Class['misc::myq_gadgets']
Class['percona::server'] -> Class['misc::myq_gadgets']



# include stdlib

include base::packages
include base::insecure

include percona::repository
include percona::toolkit
include percona::sysbench

include percona::server
include percona::config
include percona::service

include misc::myq_gadgets

include test::user

include mysql::datadir

Class['mysql::datadir'] -> Class['percona::server']
Class['percona::repository'] -> Class['percona::server'] -> Class['percona::config'] -> Class['percona::service']


Class['base::packages'] -> Class['misc::myq_gadgets']
Class['base::packages'] -> Class['percona::repository']
Class['base::insecure'] -> Class['percona::repository']

Class['percona::server'] -> Class['misc::myq_gadgets']
Class['percona::repository'] -> Class['percona::toolkit']
Class['percona::repository'] -> Class['percona::sysbench']


Class['percona::service'] -> Class['test::user']

if $sysbench_load == 'true' {
	class { 'test::sysbench_load':
		schema => $schema,
		tables => $tables,
		rows => $rows,
		threads => $threads
	}
	
	Class['percona::sysbench'] -> Class['test::sysbench_load']
	Class['test::user'] -> Class['test::sysbench_load']
}

if $enable_consul == 'true' {
	info( 'enabling consul agent' )
	
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
	})
	
	
	class { 'consul':
		join_cluster => $join_cluster,
	    config_hash => $config_hash
	}

	include consul::local_dns
	
	Class['percona::server'] ~> Class['consul'] 
	Class['consul::local_dns'] -> Class['percona::service'] 
	Class['consul'] -> Class['percona::service']

}

if ( $percona_agent_api_key ) {
	include percona::agent
    
    Class['percona::service'] -> Class['percona::agent']
}

if $sysbench_skip_test_client != 'true' {
    include test::sysbench_test_script
}


