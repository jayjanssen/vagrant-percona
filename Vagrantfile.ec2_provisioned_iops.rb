# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

mysql_version = "56"
name = "beefy-percona-server"

Vagrant.configure("2") do |config|
	# Every Vagrant virtual environment requires a box to build off of.
	config.vm.hostname = name
	config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"
  
  # Provisioners
  provision_puppet( config, "base.pp" )
  provision_puppet( config, "percona_server.pp" ) { |puppet|  
    puppet.facter = {
    	"percona_server_version"	=> mysql_version,
			'innodb_buffer_pool_size' => '12G',
			'innodb_log_file_size' => '4G'
    }
  }
  provision_puppet( config, "percona_client.pp" ) { |puppet|
    puppet.facter = {
    	"percona_server_version"	=> mysql_version
    }
  }
  provision_puppet( config, "sysbench.pp" )
  
  
  
  # Providers
  provider_virtualbox( name, config, 256 ) { |vb, override|
    # If we are using Virtualbox, override percona_server.pp with the right device for the datadir
    provision_puppet( override, "percona_server.pp" ) {|puppet|
      puppet.facter = {"datadir_dev" => "dm-2"}
    }
  }
  
	provider_aws( name, config, 'm1.xlarge') { |aws, override|
    # For AWS, we want to map the proper device for this instance type
		aws.block_device_mapping = [
            {
                'DeviceName' => "/dev/sdl",
                'VirtualName' => "mysql_data",
                'Ebs.VolumeSize' => 100,
                'Ebs.DeleteOnTermination' => true,
                'Ebs.VolumeType' => 'io1',
                'Ebs.Iops' => 1000
            }
      ]
    # Also override the percona_server.pp manifest with the right datadir device
    provision_puppet( override, "percona_server.pp" ) {|puppet|
      puppet.facter = {"datadir_dev" => "xvdl"}
    }
	}
end
