class base::hostname {

exec {
        "set_hostname":
                command => "/usr/bin/hostname $vagrant_hostname"
}


}
