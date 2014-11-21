include stdlib

include base::packages
include base::insecure

include percona::repository
include percona::toolkit
include percona::sysbench

include percona::cluster::client
include percona::cluster::server
include percona::cluster::config
include percona::cluster::service
include percona::cluster::sstuser
include percona::cluster::clustercheckuser

include misc::myq_gadgets

include test::user

include mysql::datadir

Class['mysql::datadir'] -> Class['percona::cluster::server']

Class['percona::repository'] -> Class['percona::cluster::client'] -> Class['percona::cluster::server'] -> Class['percona::cluster::config'] -> Class['percona::cluster::service'] -> Class['percona::cluster::sstuser'] -> Class['percona::cluster::clustercheckuser']

Class['base::packages'] -> Class['misc::myq_gadgets']
Class['base::packages'] -> Class['percona::repository']
Class['base::insecure'] -> Class['percona::repository']

Class['percona::cluster::server'] -> Class['misc::myq_gadgets']
Class['percona::repository'] -> Class['percona::toolkit']
Class['percona::repository'] -> Class['percona::sysbench']


Class['percona::cluster::service'] -> Class['test::user']

if $sysbench_load == 'true' {
	class { 'test::sysbench_load':
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
		'bind_addr'   => $bind_addr,
        'client_addr' => '0.0.0.0',
	})
	
	
	class { 'consul':
		join_cluster => $join_cluster,
	    config_hash => $config_hash
	}

	include consul::local_dns
	
	Class['percona::cluster::server'] ~> Class['consul'] 
	Class['consul::local_dns'] -> Class['percona::cluster::service'] 
	Class['consul'] -> Class['percona::cluster::service']

}

if ( $percona_agent_enabled == true or $percona_agent_enabled == 'true' ) {
	include percona::agent
    
    Class['percona::cluster::service'] -> Class['percona::agent']
}

unless $sysbench_skip_test_client == 'true' {
    include test::sysbench_test_script
}


