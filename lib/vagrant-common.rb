# Configure this node for AWS
# -- config: vm config from Vagrantfile
# -- name: name for the node displayed on the aws console
# -- instance_type: http://aws.amazon.com/ec2/instance-types/
# -- region: defaults to 'us-east-1'
def provider_aws( name, config, instance_type, region = nil, security_groups = nil )
	require 'yaml'

	aws_secrets_file = File.join( Dir.home, '.aws_secrets' )
	
	if( File.readable?( aws_secrets_file ))
		config.vm.provider :aws do |aws, override|
			aws.instance_type = instance_type
		
			aws_config = YAML::load_file( aws_secrets_file )
			aws.access_key_id = aws_config.fetch("access_key_id")
			aws.secret_access_key = aws_config.fetch("secret_access_key")

			aws.tags = {
				'Name' => aws_config.fetch("instance_name_prefix") + " " + name
			}
		
			if region == nil
				aws.keypair_name = aws_config["keypair_name"]
				override.ssh.private_key_path = aws_config["keypair_path"]
			else
				aws.region = region
				aws.keypair_name = aws_config['regions'][region]["keypair_name"]
				override.ssh.private_key_path = aws_config['regions'][region]["keypair_path"]
			end
		
			if security_groups != nil
				aws.security_groups = security_groups
			end
		
			yield( aws, override )
		end
	else
		puts "Skipping AWS because of missing/non-readable #{aws_secrets_file} file.  Read https://github.com/jayjanssen/vagrant-percona/blob/master/README.md#aws-setup for more information about setting up AWS."
	end
end

# Configure this node for Virtualbox
# -- config: vm config from Vagrantfile
# -- ram: amount of RAM (in MB)
def provider_virtualbox ( name, config, ram )
	config.vm.provider "virtualbox" do |vb, override|
        vb.name = name
        vb.customize ["modifyvm", :id, "--memory", ram, "--ioapic", "on" ]

        if block_given?
          yield( vb, override )
        end
	end	
end

# Provision this node with Puppet
# -- config: vm config from Vagrantfile
# -- manifest_file: puppet manifest to use (under puppet/manifests)
def provision_puppet( config, manifest_file )
  config.vm.provision "puppet", id: manifest_file, preserve_order: true do |puppet|
		puppet.manifest_file = manifest_file
    puppet.manifests_path = ["vm", "/vagrant/manifests"]
    puppet.options = "--verbose --modulepath /vagrant/modules"
    # puppet.options = "--verbose"
    if block_given?  
      yield( puppet )
    end
	end
end
