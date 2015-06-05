# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + '/lib/vagrant-common.rb'

# Number of servers
ps_servers = 1

# AWS configuration
aws_region = "us-east-1"
aws_ips='private' # Use 'public' for cross-region AWS.  'private' otherwise (or commented out)
security_groups = []


Vagrant.configure("2") do |config|
	config.vm.box = "perconajayj/centos-x86_64"
	config.vm.box_version = "~> 7"
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
          'innodb_log_file_size' => '64M',
          # Datadir setup
          'datadir_fs' => 'ext4',

          'innodb_flush_log_at_trx_commit' => '0',
         
          # Sysbench setup
          'sysbench_load' => (i == 1 ? true : false ),
          'tables' => 1,
          'rows' => 1000000,
          'threads' => 1,
          'tx_rate' => 10,
          
          # TokuDB setup
          'tokudb_enable' => true,
          'tokudb_directio' => 'ON',
          'tokudb_loader_memory_size' => '64M',
          'tokudb_fsync_log_period' => '0',
          'tokudb_cache_size' => '128M',
            
          # PCT setup
          'percona_agent_api_key' => ENV['PERCONA_AGENT_API_KEY']
        }
      }

      # Providers
      provider_virtualbox( name, node_config, 1024 ) { |vb, override|
        provision_puppet( override, "percona_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            'datadir_dev' => 'dm-2',
          }
        }
      }

      provider_vmware( name, node_config, 1024 ) { |vb, override|
        provision_puppet( override, "percona_server.pp" ) {|puppet|
          puppet.facter = {
            'default_interface' => 'eth1',
            'datadir_dev' => 'dm-2',
          }
        }
      }
  
      provider_aws( "Percona Server #{name}", node_config, 't2.small', aws_region, security_groups, aws_ips) { |aws, override|

        aws.block_device_mapping = [
            {
                'DeviceName' => "/dev/sdl",
                'VirtualName' => "mysql_data",
                'Ebs.VolumeSize' => 20,
                'Ebs.DeleteOnTermination' => true,
            }
        ]


        provision_puppet( override, "percona_server.pp" ) { |puppet| 
          puppet.facter = {'datadir_dev' => 'xvdl'}        
        }
      }

    end
  end
  
end
