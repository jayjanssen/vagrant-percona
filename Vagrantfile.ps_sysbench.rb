# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

# Number of servers
ps_servers = 1

# AWS configuration
aws_region = "us-west-1"
aws_ips='private' # Use 'public' for cross-region AWS.  'private' otherwise (or commented out)
security_groups = ['default']


Vagrant.configure("2") do |config|
	config.vm.box = "perconajayj/centos-x86_64"
	config.vm.box_version = "~> 7.0"
	config.ssh.username = "root"

  # Create the PXC nodes
  (1..ps_servers).each do |i|
    name = "ps" + i.to_s
    config.vm.define name do |node_config|
      node_config.vm.hostname = name
      node_config.vm.network :private_network, type: "dhcp"
      node_config.vm.provision :hostmanager
      
      # Provisioners
      provision_puppet( node_config, "percona_server.pp" ) { |puppet| 
        puppet.facter = {
          # PXC setup
          "percona_server_version"  => '56',
          'innodb_buffer_pool_size' => '128M',
          'innodb_log_file_size' => '64Mf',
          'innodb_flush_log_at_trx_commit' => '0',
         
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
      provider_virtualbox( name, node_config, 256 ) { |vb, override|
        provision_puppet( override, "percona_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            
            # PXC Setup
            'datadir_dev' => 'dm-2',
          }
        }
      }
  
      provider_aws( "Percona Server #{name}", node_config, 'm1.small', aws_region, security_groups, aws_ips) { |aws, override|
        aws.block_device_mapping = [
          { 'DeviceName' => "/dev/sdb", 'VirtualName' => "ephemeral0" }
        ]
        provision_puppet( override, "percona_server.pp" ) {|puppet| puppet.facter = { 'datadir_dev' => 'xvdb' }}
      }

    end
  end
  
end
