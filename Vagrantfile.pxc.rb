# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/jayjanssen/packer-percona

# This sets up 3 nodes with a common PXC, but you need to run bootstrap.sh to connect them.

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

mysql_version = "56"

# Node names and ips (for local VMs)
pxc_nodes = {
	'node1' => '192.168.70.2',
	'node2' => '192.168.70.3',
	'node3' => '192.168.70.4',
}

Vagrant.configure("2") do |config|
	config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"

	# Create all three nodes identically except for name and ip
	pxc_nodes.each_pair { |name, ip|
		config.vm.define name do |node_config|
			node_config.vm.hostname = name
			node_config.vm.network :private_network, ip: ip
      
      # Provisioners
      provision_puppet( config, "base.pp" )
      provision_puppet( config, "pxc_server.pp" ) { |puppet|  
        puppet.facter = {
        	"percona_server_version"	=> mysql_version,
        	'innodb_buffer_pool_size' => '128M',
        	'innodb_log_file_size' => '64M',
        	'innodb_flush_log_at_trx_commit' => '0'
        }
      }
      provision_puppet( config, "pxc_client.pp" ) { |puppet|
        puppet.facter = {
        	"percona_server_version"	=> mysql_version
        }
      }
      provision_puppet( config, "sysbench.pp" )
      provision_puppet( config, "percona_toolkit.pp" )
      provision_puppet( config, "myq_gadgets.pp" )
  
      # Providers
      provider_virtualbox( name, config, 256 ) { |vb, override|
        provision_puppet( override, "pxc_server.pp" ) {|puppet|
          puppet.facter = {"datadir_dev" => "dm-2"}
        }
      }
  
    	provider_aws( name, config, 'm1.small') { |aws, override|
    		aws.block_device_mapping = [
    			{
    				'DeviceName' => "/dev/sdb",
    				'VirtualName' => "ephemeral0"
    			}
    		]
        provision_puppet( override, "pxc_server.pp" ) {|puppet|
          puppet.facter = {"datadir_dev" => "xvdb"}
        }
    	}

		end
	}
end

