# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/jayjanssen/packer-percona

# This sets up 3 nodes with a common PXC, but you need to run bootstrap.sh to connect them.

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

pxc_version = "56"

# Node group counts and aws security groups (if using aws provider)
pxc_nodes = 3
pxc_node_name_prefix = "node"

# AWS configuration
aws_region = "us-west-1"
aws_ips='private' # Use 'public' for cross-region AWS.  'private' otherwise (or commented out)
pxc_security_groups = ['default','pxc']

cluster_address = 'gcomm://' + Array.new( pxc_nodes ){ |i| pxc_node_name_prefix + (i+1).to_s }.join(',')


Vagrant.configure("2") do |config|
	config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"

  # Create the PXC nodes
  (1..pxc_nodes).each do |i|
    name = pxc_node_name_prefix + i.to_s
    config.vm.define name do |node_config|
      node_config.vm.hostname = name
      node_config.vm.network :private_network, type: "dhcp"
      node_config.vm.provision :hostmanager
      
      # Provisioners
      provision_puppet( node_config, "pxc_server.pp" ) { |puppet| 
        puppet.facter = {
          # PXC setup
          "percona_server_version"  => pxc_version,
          'innodb_buffer_pool_size' => '12G',
          'innodb_log_file_size' => '1G',
          'innodb_flush_log_at_trx_commit' => '0',
          'pxc_bootstrap_node' => (i == 1 ? true : false ),
          'wsrep_cluster_address' => cluster_address,
          'wsrep_provider_options' => 'gcache.size=128M; gcs.fc_limit=1024; evs.user_send_window=512; evs.send_window=512',
          'wsrep_slave_threads' => 8,
          
          # Sysbench setup
          'sysbench_load' => (i == 1 ? true : false ),
          'tables' => 20,
          'rows' => 1000000,
          'threads' => 8,
          # 'tx_rate' => 10,
          
          # PCT setup
          'percona_agent_api_key' => ENV['PERCONA_AGENT_API_KEY']
        }
      }

      # Providers
      provider_virtualbox( name, node_config, 256 ) { |vb, override|
        provision_puppet( override, "pxc_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            
            # PXC Setup
            'datadir_dev' => 'dm-2',
          }
        }
      }
      provider_vmware( name, node_config, 256 ) { |vb, override|
        provision_puppet( override, "pxc_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            
            # PXC Setup
            'datadir_dev' => 'dm-2',
          }
        }
      }
  
      provider_aws( "PXC #{name}", node_config, 'm3.xlarge', aws_region, pxc_security_groups, aws_ips) { |aws, override|
        aws.block_device_mapping = [
          { 'DeviceName' => "/dev/sdb", 'VirtualName' => "ephemeral0" },
          { 'DeviceName' => "/dev/sdc", 'VirtualName' => "ephemeral1" }
        ]
        provision_puppet( override, "pxc_server.pp" ) {|puppet| puppet.facter = { 
            'softraid' => true,
            'softraid_dev' => '/dev/md0',
            'softraid_level' => 'stripe',
            'softraid_devices' => '2',
            'softraid_dev_str' => '/dev/xvdb /dev/xvdc',

            'datadir_dev' => 'md0'
          }}
      }

    end
  end
  
end

