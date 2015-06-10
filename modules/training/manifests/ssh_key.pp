class training::ssh_key {

	ssh_authorized_key {$title:
		ensure          => present,
		name            => 'percona-training',
		user            => 'root',
		type            => ssh-rsa,
		key             => "AAAAB3NzaC1yc2EAAAADAQABAAABAQCPPDcD4/1gZY8EZaCuYZq7l4KdnPzkr2LIi94pa7GQ6vAg9l/o2MDXNrBT+P7sjfbzRurR633wD5NkERWx8TdRPIZRaZKYp6F4CbOf+LtEYw9dF3CwZVjFHKLqEsKEDMnbpwbaL33RycbjDh3cTHHN65WxiWKhX2yMIwxj3q+rGbx2CP+IUtP59hxc3iz/Fddm3JziB0N4bd0kPL3f8CtdXpmgz+rScL73+L7L0gmF453qXdCYc8wWRdNLhDyxC9nTBDheKEDasyYiprdeuT1D/Nj0eeN/jppU1GJfZ81rryfBRoXShu4yPc0TwDUgF9L9wQiY0lYdVSIh0wbano+B"
    }

}
