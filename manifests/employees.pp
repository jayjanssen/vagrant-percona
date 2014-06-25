include base::packages
include misc::employees

Class['base::packages'] -> Class['misc::employees']