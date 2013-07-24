class percona::cluster {

	include percona::cluster::packages
	include percona::cluster::config  
	include percona::cluster::service    
	include percona::cluster::sst_config

	Class['percona::cluster::packages'] -> Class['percona::cluster::config'] -> Class['percona::cluster::service'] -> Class['percona::cluster::sst_config']

}