# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu-aws-us-east"

	config.vm.provider :aws do |aws, override|
		aws_config = YAML::load_file(File.join(Dir.home, ".aws_secrets"))
		aws.access_key_id = aws_config.fetch("access_key_id")
		aws.secret_access_key = aws_config.fetch("secret_access_key")
		aws.keypair_name = aws_config.fetch("keypair_name")
		override.ssh.username = "ubuntu"
		override.ssh.private_key_path = aws_config.fetch("keypair_path")
		#aws.instance_type="m3.xlarge"
	end

  config.vm.provision :puppet do |puppet|
		puppet.manifests_path = "puppet/manifests"
		puppet.manifest_file  = "init.pp"
		puppet.module_path = "puppet/modules"
		puppet.options = "--verbose"
  end


end
