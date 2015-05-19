# -*- mode: ruby -*-
# vi: set ft=ruby :

# Example of a beefier EC2 instance

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'aws'


# Assumes a box from https://github.com/jayjanssen/packer-percona
require './lib/vagrant-common.rb'

Vagrant.configure("2") do |config|
	# Every Vagrant virtual environment requires a box to build off of.
	config.vm.box = "perconajayj/centos-x86_64"
	config.ssh.username = "root"

	# We are assuming AWS, create a 'm1.xlarge' and name it 
	provider_aws( "Beefy Percona Server", config, 'c4.2xlarge') { |aws, override|
		# Setup the 1k provisioned iops 100G EBS drive under sdl
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

		# Provision this node with puppet and the 'percona_server.pp' manifest.
		# - We use 'xvdl' instead of 'sdl' because of how /sys/block presents 
		# 	the device on EC2, but this is our ephemeral drive above.
		# - We override the buffer pool here because m1.small has 1.5G of RAM
		provision_puppet( override, 'percona_server.pp') { |puppet|
			puppet.facter = {
				'datadir_dev' => 'xvdl',
				'innodb_buffer_pool_size' => '12G',
				'innodb_log_file_size' => '4G',

				# Sysbench setup
				'sysbench_load' => true,
				'tables' => 20,
				'rows' => 1000000,
				'threads' => 64
			}
		}
	}
end
