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
aws_region = "us-east-1"
aws_ips='private' # Use 'public' for cross-region AWS.  'private' otherwise (or commented out)
pxc_security_groups = []

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
          'innodb_buffer_pool_size' => '128M',
          'innodb_log_file_size' => '64M',
          'innodb_flush_log_at_trx_commit' => '0',
          'pxc_bootstrap_node' => (i == 1 ? true : false ),
          'wsrep_cluster_address' => cluster_address,
          'wsrep_provider_options' => 'gcache.size=128M; gcs.fc_limit=128',
          
          # Sysbench setup
          'sysbench_load' => (i == 1 ? true : false ),
          'tables' => 1,
          'rows' => 100000,
          'threads' => 8,
          
          # PCT setup
          'percona_agent_api_key' => ENV['PERCONA_AGENT_API_KEY']
        }
      }

      # Providers
      provider_virtualbox( name, node_config, 1024 ) { |vb, override|
        provision_puppet( override, "pxc_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            
            # PXC Setup
            'datadir_dev' => 'dm-2',
          }
        }
      }
      provider_vmware( name, node_config, 1024 ) { |vb, override|
        provision_puppet( override, "pxc_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            
            # PXC Setup
            'datadir_dev' => 'dm-2',
          }
        }
      }
  
      provider_aws( "PXC #{name}", node_config, 't2.small', aws_region, pxc_security_groups, aws_ips) { |aws, override|
        aws.block_device_mapping = [
            {
                'DeviceName' => "/dev/sdl",
                'VirtualName' => "mysql_data",
                'Ebs.VolumeSize' => 20,
                'Ebs.DeleteOnTermination' => true,
            }
        ]
        provision_puppet( override, "pxc_server.pp" ) {|puppet| puppet.facter = { 'datadir_dev' => 'xvdl' }}
      }

    end
  end
  
end

