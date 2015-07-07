# Configure this node for AWS
# -- config: vm config from Vagrantfile
# -- name: name for the node displayed on the aws console
# -- instance_type: http://aws.amazon.com/ec2/instance-types/
# -- region: defaults to 'us-east-1'
# -- hostmanager_aws_ips: when using hostmanager, should we use 'public' or 'private' ips?

$aws_ip_cache = Hash.new
def provider_aws( name, config, instance_type, region = nil, security_groups = nil, hostmanager_aws_ips = nil, subnet_id = nil )
	require 'yaml'

	aws_secrets_file = File.join( Dir.home, '.aws_secrets' )
	
	if( File.readable?( aws_secrets_file ))
		config.vm.provider "aws" do |aws, override|
			aws.instance_type = instance_type
		
			aws_config = YAML::load_file( aws_secrets_file )
			aws.access_key_id = aws_config.fetch("access_key_id")
			aws.secret_access_key = aws_config.fetch("secret_access_key")

			aws.tags = {
				'Name' => aws_config.fetch("instance_name_prefix") + " " + name
			}

			# Used_subnet_id can be overridden if it is nil
			used_subnet_id = subnet_id

			if region == nil
				aws.keypair_name = aws_config["keypair_name"]
				override.ssh.private_key_path = aws_config["keypair_path"]

				if used_subnet_id == nil 
					used_subnet_id = aws_config.fetch("default_vpc_subnet_id")
				end
			elsif aws_config['regions'][region] != nil
				aws.region = region
				aws.keypair_name = aws_config['regions'][region]["keypair_name"]
				override.ssh.private_key_path = aws_config['regions'][region]["keypair_path"]

				if used_subnet_id == nil 
					used_subnet_id = aws_config['regions'][region]["default_vpc_subnet_id"]
				end
			else
				puts "Warning: AWS region #{region} not defined in your ~/.aws_secrets file."
			end

			if used_subnet_id != nil
				# We assume if the vpc_subnet_id is set, then we should use it.
				aws.subnet_id = used_subnet_id
				aws.associate_public_ip = true
			end
		
			if security_groups != nil
				aws.security_groups = security_groups
			end
			
			if Vagrant.has_plugin?("vagrant-hostmanager")
				
				if hostmanager_aws_ips == "private" or hostmanager_aws_ips == nil
					awsrequest = "local-ipv4"
				elsif hostmanager_aws_ips == "public"
					awsrequest = "public-ipv4"
				end

				override.hostmanager.ip_resolver = proc do |vm|
					if $aws_ip_cache[name] == nil
						vm.communicate.execute("curl -s http://169.254.169.254/latest/meta-data/" + awsrequest + " 2>&1") do |type,data|
							$aws_ip_cache[name] = data if type == :stdout
						end
					end
					$aws_ip_cache[name]
				end
			end

      if block_given?
			  yield( aws, override )
      end
		end
	else
		puts "Skipping AWS because of missing/non-readable #{aws_secrets_file} file.  Read https://github.com/jayjanssen/vagrant-percona/blob/master/README.md#aws-setup for more information about setting up AWS."
	end
end

# Configure this node for Virtualbox
# -- config: vm config from Vagrantfile
# -- ram: amount of RAM (in MB)
def provider_virtualbox ( name, config, ram = 256, cpus = 1 )
	config.vm.provider "virtualbox" do |vb, override|
    vb.name = name
    vb.cpus = cpus
    vb.memory = ram
    
    vb.customize ["modifyvm", :id, "--ioapic", "on" ]

    # fix for slow dns https://github.com/mitchellh/vagrant/issues/1172
  	vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
		vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    
    # Custom ip resolver that works with DHCP or explicit addresses (and is fast)
    override.hostmanager.ip_resolver = proc do |vm, resolving_vm|
      if vm.id
        `VBoxManage guestproperty get #{vm.id} "/VirtualBox/GuestInfo/Net/1/V4/IP"`.split()[1]
      end
    end

    if block_given?
      yield( vb, override )
    end
	end	
end

# Configure this node for VMware
# -- config: vm config from Vagrantfile
# -- ram: amount of RAM (in MB)
def provider_vmware ( name, config, ram = 256, cpus = 1 )
	config.vm.provider "vmware_fusion" do |v, override|
	    v.name = name
	    v.vmx["memsize"] = ram
	    v.vmx["numvcpus"] = cpus

	    if block_given?
	      yield( v, override )
	    end
	end	
end


# Configure this node for Vmware
def provider_openstack( name, config, flavor, security_groups = nil, networks = nil, floating_ip = nil )
    require 'yaml'
    require 'vagrant-openstack-plugin'

    os_secrets_file = File.join( Dir.home, '.openstack_secrets' )

    if( File.readable?( os_secrets_file ))
        config.vm.provider :openstack do |os, override|
            os.flavor = flavor

            os_config = YAML::load_file( os_secrets_file )

            os.endpoint = os_config.fetch("endpoint")
            os.username = os_config.fetch("username")
            os.api_key = os_config.fetch("password")
            os.tenant= os_config.fetch("tenant")

            os.keypair_name = os_config.fetch("keypair_name")
            override.ssh.private_key_path = os_config.fetch("private_key_path")


            if security_groups != nil
                os.security_groups = security_groups
            end

            if networks != nil
                os.networks = networks
            end


            if floating_ip != nil
                os.floating_ip = floating_ip
                os.floating_ip_pool = :auto
            end

            if block_given?
                yield( os, override )
            end
        end
    else
        puts "Skipping Openstack because of missing/non-readable #{os_secrets_file} file.  Read https://github.com/jayjanssen/vagrant-percona/blob/master/README.md#os-setup for more information about setting up Openstack."
    end
end

# Provision this node with Puppet
# -- config: vm config from Vagrantfile
# -- manifest_file: puppet manifest to use (under puppet/manifests)
def provision_puppet( config, manifest_file )
  config.vm.provision manifest_file, type:"puppet", preserve_order: true do |puppet|
		puppet.manifest_file = manifest_file
	    puppet.manifests_path = ["vm", "/vagrant/manifests"]
	    puppet.options = "--verbose --modulepath /vagrant/modules"
	    # puppet.options = "--verbose"
	    if block_given?  
	      yield( puppet )
	    end

	    # Check if the hostname is a proper string (won't be if config is an override config)
	    # If string, then set the vagrant_hostname facter fact automatically so base::hostname works
		if config.vm.hostname.is_a?(String)
			puppet.facter["vagrant_hostname"] = config.vm.hostname 
	    end

	end
end
