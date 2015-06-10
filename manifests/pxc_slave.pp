# different tools which are used to setup lot's of stuff for pxc and to test/train...

include test::sysbench_custom_lua


# all other defaults
include percona::repository


include percona::toolkit

Class['percona::repository'] -> Class['percona::toolkit']

include base::packages
include base::insecure
include base::hostname
include misc::myq_gadgets

Class['base::packages'] -> Class['misc::myq_gadgets']

include haproxy::server-pxc

include mysql::datadir



if ( $percona_agent_enabled == true or $percona_agent_enabled == 'true' ) {
	include percona::agent
}
