# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/jayjanssen/packer-percona

# This sets up 3 nodes with a common PXC, but you need to run bootstrap.sh to connect them.

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

pxc_version = "56"

# Node group counts and aws security groups (if using aws provider)
pxc_nodes = 3

# AWS configuration
aws_region = "us-west-1"
aws_ips='private' # Use 'public' for cross-region AWS.  'private' otherwise (or commented out)
pxc_security_groups = ['default','pxc']

cluster_address = 'gcomm://' + Array.new( pxc_nodes ){ |i| "pxc" + (i+1).to_s }.join(',')


Vagrant.configure("2") do |config|
	config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"

  # Create the PXC nodes
  (1..pxc_nodes).each do |i|
    name = "pxc" + i.to_s
    config.vm.define name do |node_config|
      node_config.vm.hostname = name
      node_config.vm.network :private_network, type: "dhcp"
      node_config.vm.provision :hostmanager
      
      # Provisioners
      provision_puppet( node_config, "pxc_server.pp" ) { |puppet| 
        puppet.facter = {
          # PXC setup
          "percona_server_version"  => pxc_version,
          'innodb_buffer_pool_size' => '1G',
          'innodb_log_file_size' => '1G',
          'innodb_flush_log_at_trx_commit' => '0',
          'pxc_bootstrap_node' => (i == 1 ? true : false ),
          'wsrep_cluster_address' => cluster_address,
          'wsrep_provider_options' => 'gcache.size=2G; gcs.fc_limit=1024',
          
          # Sysbench setup
          'sysbench_load' => (i == 1 ? true : false ),
          'tables' => 1,
          'rows' => 1000000,
          'threads' => 1,
          'tx_rate' => 10,
          
          # PCT setup
          'percona_agent_api_key' => ENV['PERCONA_AGENT_API_KEY']
        }
      }

      # Providers
      provider_virtualbox( name, node_config, 2048 ) { |vb, override|
        provision_puppet( override, "pxc_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            
            # PXC Setup
            'datadir_dev' => 'dm-2',
          }
        }
      }
  
      provider_aws( "PXC #{name}", node_config, 'm3.large', aws_region, pxc_security_groups, aws_ips) { |aws, override|
        aws.block_device_mapping = [
          { 'DeviceName' => "/dev/sdb", 'VirtualName' => "ephemeral0" }
        ]
        provision_puppet( override, "pxc_server.pp" ) {|puppet| puppet.facter = { 'datadir_dev' => 'xvdb' }}
      }

    end
  end
  
end

