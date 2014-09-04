# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/jayjanssen/packer-percona

# This sets up 3 nodes with a common PXC, but you need to run bootstrap.sh to connect them.

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

mysql_version = "56"

# Node names and ips (for local VMs)
# (Amazon) aws_region is where to bring up the node
# (Amazon) Security groups are 'default' (22 open) and 'pxc' (3306, 4567-4568,4444 open) for each respective region
# Don't worry about amazon config if you are not using that provider.
pxc_nodes = {
	'node1' => {
		'local_vm_ip' => '192.168.70.2',
		'aws_region' => 'us-east-1',
		'security_groups' => ['default','pxc']
	},
	'node2' => {
		'local_vm_ip' => '192.168.70.3',
		'aws_region' => 'us-east-1',
		'security_groups' => ['default','pxc'] 
	},
	'node3' => {
		'local_vm_ip' => '192.168.70.4',
		'aws_region' => 'us-east-1',
		'security_groups' => ['default','pxc']
	}
}

# Use 'public' for cross-region AWS.  'private' otherwise (or commented out)
hostmanager_aws_ips='private'

sysbench_setup= {
	'tables' => 1,
	'rows' => 1000000,
	'threads' => 1,
	'tx_rate' => 10
}

$cluster_address = "gcomm://" + pxc_nodes.keys().join(',')


Vagrant.configure("2") do |config|
	config.vm.box = "perconajayj/centos-x86_64"
	config.vm.box_version = "~> 6.5"
	config.ssh.username = "root"

    config.hostmanager.enabled = true # Disable for AWS
    config.hostmanager.include_offline = true

	# Create all three nodes identically except for name and ip
	pxc_nodes.each_pair { |name, node_params|
		config.vm.define name do |node_config|
			node_config.vm.hostname = name
			node_config.vm.network :private_network, ip: node_params['local_vm_ip']

			node_config.vm.provision :hostmanager
			
			# Provisioners
			provision_puppet( node_config, "base.pp" )
			provision_puppet( node_config, "pxc_server.pp" ) { |puppet|	
				puppet.facter = {
					"percona_server_version"	=> mysql_version,
					'innodb_buffer_pool_size' => '128M',
					'innodb_log_file_size' => '64M',
					'innodb_flush_log_at_trx_commit' => '0',
					'pxc_bootstrap_node' => (name == 'node1' ? true : false ),
					'extra_mysqld_config' => "
wsrep_provider_options = \"ist.recv_addr=#{name}\"
wsrep_node_address = #{name}
wsrep_cluster_address = #{$cluster_address}
"
				}
			}
			provision_puppet( node_config, "percona_toolkit.pp" )
			provision_puppet( node_config, "myq_gadgets.pp" )

			provision_puppet( node_config, "sysbench.pp" ) { |puppet|
				puppet.facter = sysbench_setup
			}
			provision_puppet( node_config, "test_user.pp" )

			# Setup a sysbench environment and test user on node1
			if name == 'node1'
			  provision_puppet( node_config, "sysbench_load.pp" ) { |puppet|
					puppet.facter = sysbench_setup
				}
			end

			# Providers
			provider_virtualbox( name, node_config, 256 ) { |vb, override|
				provision_puppet( override, "pxc_server.pp" ) {|puppet|
					puppet.facter = {
						'datadir_dev' => 'dm-2',
						# /etc/hosts is weird w/ VB and Vagrant, so we use the ips 
						# instead.  This may apply to other local vms as well.
						'extra_mysqld_config' => "
wsrep_provider_options = \"ist.recv_addr=#{node_params['local_vm_ip']}\"
wsrep_node_address = #{node_params['local_vm_ip']}
wsrep_cluster_address = #{$cluster_address}
"
					}
				}
			}
	
			provider_aws( "PXC #{name}", node_config, 'm1.small', node_params['aws_region'], node_params['security_groups'], hostmanager_aws_ips) { |aws, override|
				aws.block_device_mapping = [
					{
						'DeviceName' => "/dev/sdb",
						'VirtualName' => "ephemeral0"
					}
				]
				provision_puppet( override, "pxc_server.pp" ) {|puppet|
					puppet.facter = {
						'datadir_dev' => 'xvdb',
						# /etc/hosts is weird w/ VB and Vagrant, so we use the ips 
						# instead.  This may apply to other local vms as well.
						'extra_mysqld_config' => "
wsrep_node_address = #{name}
wsrep_cluster_address = #{$cluster_address}
"
					}
				}
			}

		end
	}
end

