# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/jayjanssen/packer-percona

# This sets up 3 nodes with a common PXC, but you need to run bootstrap.sh to connect them.

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

mysql_version = "56"

# Node names and ips (for local VMs)
# (Amazon) aws_region is where to bring up the node
# (Amazon) Security groups are 'default' (23 open) and 'pxc' (3306, 4567-4568,4444 open) for each respective region
# (Amazon) HAproxy also needs the 'haproxy' security group (3307-3309, 8000) for each respective region
# Don't worry about amazon config if you are not using that provider.
pxc_nodes = {
	'node1' => {
		'local_vm_ip' => '192.168.70.2',
		'aws_region' => 'us-east-1',
		'security_groups' => ['default','pxc']
	},
	'node2' => {
		'local_vm_ip' => '192.168.70.3',
		'aws_region' => 'us-west-1',
		'security_groups' => ['default','pxc'] 
	},
	'node3' => {
		'local_vm_ip' => '192.168.70.4',
		'aws_region' => 'eu-west-1',
		'security_groups' => ['default','pxc']
	}
}


Vagrant.configure("2") do |config|
	config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"
	config.hostmanager.enabled = true
	config.hostmanager.include_offline = true


	# Create all three nodes identically except for name and ip
	pxc_nodes.each_pair { |name, node_params|
		config.vm.define name do |node_config|
			node_config.vm.hostname = name
			node_config.vm.network :private_network, ip: node_params['local_vm_ip']
			
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
			provision_puppet( config, "haproxy-pxc.pp" )
	
			# Providers
			provider_virtualbox( name, config, 256 ) { |vb, override|
				provision_puppet( override, "pxc_server.pp" ) {|puppet|
					puppet.facter = {"datadir_dev" => "dm-2"}
				}
			}
	
			provider_aws( "PXC #{name}", config, 'm1.small', node_params['aws_region'], node_params['security_groups']) { |aws, override|
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

