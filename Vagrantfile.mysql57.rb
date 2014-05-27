# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

mysql_version = "56"
name = "5.7-community-tpcc"

Vagrant.configure("2") do |config|
	# Every Vagrant virtual environment requires a box to build off of.
	config.vm.hostname = name
	config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"
  
  # Provisioners
  provision_puppet( config, "base.pp" )
  provision_puppet( config, "mysql_server.pp" ) { |puppet|  
    puppet.facter = {
      "enable_56" => 0,
      "enable_57" => 1,
    	"innodb_buffer_pool_size"	=> "128M",
    	"innodb_log_file_size"		=> "64M"
    }
  }
  provision_puppet( config, "mysql_client.pp" ) { |puppet|
    puppet.facter = {
      "enable_56" => 0,
      "enable_57" => 1
    }
  }
  provision_puppet( config, "tpcc.pp" )
  provision_puppet( config, "sysbench_build.pp" )
  provision_puppet( config, "percona_toolkit.pp" )
  
  # Providers
  provider_virtualbox( name, config, 256 ) { |vb, override|
    # If we are using Virtualbox, override percona_server.pp with the right device for the datadir
    provision_puppet( override, "mysql_server.pp" ) {|puppet|
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
    provision_puppet( override, "mysql_server.pp" ) {|puppet|
      puppet.facter = {
  			'datadir_dev' => 'xvdb',
  			'innodb_buffer_pool_size' => '1G'
      }
    }
	}

  
end


