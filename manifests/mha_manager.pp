include base::packages

include mha::manager
include mha::node

Class['mha::node'] -> Class['mha::manager']
