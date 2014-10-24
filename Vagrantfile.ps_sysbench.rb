# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

mysql_version = "56"
name = "pssysbench"

sysbench_setup= {
	'tables' => 1,
	'rows' => 1000000,
	'threads' => 1,
	'tx_rate' => 10
}

Vagrant.configure("2") do |config|
	# Every Vagrant virtual environment requires a box to build off of.
	config.vm.hostname = name
	config.vm.box = "perconajayj/centos-x86_64"
	#config.vm.box_version = "~> 6.5"
	config.vm.box_version = "~> 7.0"
	config.ssh.username = "root"
  
  # Provisioners
  provision_puppet( config, "base.pp" )
  provision_puppet( config, "percona_server.pp" ) { |puppet|  
    puppet.facter = {
    	"percona_server_version"	=> mysql_version,
    	"innodb_buffer_pool_size"	=> "128M",
    	"innodb_log_file_size"		=> "64M"
    }
  }
  provision_puppet( config, "percona_client.pp" ) { |puppet|
    puppet.facter = {
    	"percona_server_version"	=> mysql_version
    }
  }
	provision_puppet( config, "sysbench.pp" ) { |puppet|
		puppet.facter = sysbench_setup
	}
    
	provision_puppet( config, "test_user.pp" )

  provision_puppet( config, "sysbench_load.pp" ) { |puppet|
		puppet.facter = sysbench_setup
	}
  
  # Providers
  provider_virtualbox( name, config, 256 ) { |vb, override|
    # If we are using Virtualbox, override percona_server.pp with the right device for the datadir
    provision_puppet( override, "percona_server.pp" ) {|puppet|
      puppet.facter = {"datadir_dev" => "dm-2"}
    }
  }
  
	provider_aws( name, config, 'm1.small') { |aws, override|
    # For AWS, we want to map the proper device for this instance type
		aws.block_device_mapping = [
			{
				'DeviceName' => "/dev/sdb",
				'VirtualName' => "ephemeral0"
			}
		]
    # Also override the percona_server.pp manifest with the right datadir device
    provision_puppet( override, "percona_server.pp" ) {|puppet|
      puppet.facter = {"datadir_dev" => "xvdb"}
    }
	}

  
end
