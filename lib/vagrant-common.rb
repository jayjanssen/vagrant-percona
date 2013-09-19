# Configure this node for AWS
# -- config: vm config from Vagrantfile
# -- name: name for the node displayed on the aws console
# -- instance_type: http://aws.amazon.com/ec2/instance-types/
# -- region: defaults to 'us-east-1'
def provider_aws( config, name, instance_type, region = nil, security_groups = nil )
	require 'yaml'

	config.vm.provider :aws do |aws, override|
		aws.instance_type = instance_type
		
		aws_config = YAML::load_file(File.join(Dir.home, ".aws_secrets"))
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
end

# Configure this node for Virtualbox
# -- config: vm config from Vagrantfile
# -- ram: amount of RAM (in MB)
def provider_virtualbox ( config, ram )
	config.vm.provider :virtualbox do |vb, override|
        vb.customize ["modifyvm", :id, "--memory", ram, "--ioapic", "on" ]

        yield( vb, override )
	end	
end

# Provision this node with Puppet
# -- config: vm config from Vagrantfile
# -- manifest_file: puppet manifest to use (under puppet/manifests)
# -- facter: hash of facter parameters to pass into puppet (not modified!)
# -- extra_facter: just like facter, but merged with facter in a local copy 
# 	 	here.  This is necessary because of how Vagrant does provider-specific 
# 		overrides.  These will override any common settings in the facter arg.
def provision_puppet( config, manifest_file, facter = {}, extra_facter = {} )
	config.vm.provision :puppet do |puppet|
		puppet.manifests_path = "puppet/manifests"
		puppet.manifest_file  = manifest_file
		puppet.module_path = "puppet/modules"
		puppet.options = "--verbose"

		puppet.facter = facter.merge( extra_facter )
	end
end