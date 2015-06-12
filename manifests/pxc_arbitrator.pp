# different tools which are used to setup lot's of stuff for pxc and to test/train...


# all other defaults
include percona::repository
include percona::cluster::garb
Class['percona::repository'] -> Class['percona::cluster::garb']

include base::packages
include base::hostname
include base::insecure
include misc::myq_gadgets

Class['base::packages'] -> Class['misc::myq_gadgets']


