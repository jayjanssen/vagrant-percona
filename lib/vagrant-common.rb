
def puppet( config, manifest_file, facter = {} )
	config.vm.provision :puppet do |puppet|
		puppet.manifests_path = "puppet/manifests"
		puppet.manifest_file  = manifest_file
		puppet.module_path = "puppet/modules"
		puppet.options = "--verbose"

		puppet.facter = facter
	end
end

def aws_provider( aws, override, name )
	require 'yaml'

	aws_config = YAML::load_file(File.join(Dir.home, ".aws_secrets"))
	aws.access_key_id = aws_config.fetch("access_key_id")
	aws.secret_access_key = aws_config.fetch("secret_access_key")
	aws.keypair_name = aws_config.fetch("keypair_name")
	name = aws_config.fetch("instance_name_prefix") + " " + name
	aws.tags = {
		'Name' => name
	}
	override.ssh.private_key_path = aws_config.fetch("keypair_path")
end

