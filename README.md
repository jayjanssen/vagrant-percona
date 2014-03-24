# Vagrant + Percona 

## Introduction

This repository contains tools to build consistent environments for testing Percona software on a variety of platforms.  This includes EC2 and Virtualbox for now, but more are possible going forward.

## Walkthrough

This section should get you up and running.

### Build Vagrant boxes to use

https://github.com/jayjanssen/packer-percona

### AWS Setup

You can skip this section if you aren't planning on using AWS.  

You'll need an AWS account setup with the following information in a file called ~/.aws_secrets:

```yaml
access_key_id: YOUR_ACCESS_KEY
secret_access_key: THE_ASSOCIATED_SECRET_KEY
keypair_name: KEYPAIR_ID
keypair_path: PATH_TO_KEYPAIR_PEM
instance_name_prefix: SOME_NAME_PREFIX
```

AWS Multi-region can be supported by adding a 'regions' hash to the .aws_secrets file:

```yaml
access_key_id: YOUR_ACCESS_KEY
secret_access_key: THE_ASSOCIATED_SECRET_KEY
keypair_name: jay
keypair_path: /Users/jayj/.ssh/jay-us-east-1.pem
instance_name_prefix: Jay
regions:
  us-east-1:
    keypair_name: jay
    keypair_path: /Users/jayj/.ssh/jay-us-east-1.pem
  us-west-1:
    keypair_name: jay
    keypair_path: /Users/jayj/.ssh/jay-us-west-1.pem
  eu-west-1:
    keypair_name: jay
    keypair_path: /Users/jayj/.ssh/jay-eu-west-1.pem
```

Note that the default 'keypair_name' and 'keypair_path' can still be used.  Region will default to 'us-east-1' unless you specifically override it.    

### Software Requirements

* Vagrant 1.2+: http://vagrantup.com
* Vagrant AWS Plugin (optional):

```
 vagrant plugin install vagrant-aws
```

* VirtualBox: https://www.virtualbox.org (optional)
* VMware Fusion (not supported yet, but feasible)

#### For local VMs

If you want local VMs, be sure to install VirtualBox 


### Launch the box

* Modify Vagrantfile 
 * Instance size
 

```bash
vagrant up --provider=aws
vagrant ssh
```

### Create Environments with create-new-env.sh

When you create a lot of vagrant environments with vagrant-percona, creating/renaming those Vagrantfile files can get quite messy easily.

The repository contains a small script that allows you to create a new environment, which will build a new directory with the proper Virtualbox files and links to the puppet code. If you're setting up a PXC environment, symlinks will also be provided to the necessary pxc-bootstrap.sh script

This allows you to have many many Vagrant environments configured simultaneously.

```bash
vagrant-percona$ ./create-new-env.sh single_node ~/vagrant/percona-toolkit-ptosc-plugin-ptheartbeat
Creating 'single_node' Environment

percona-toolkit-ptosc-plugin-ptheartbeat gryp$ vagrant up --provider=aws
percona-toolkit-ptosc-plugin-ptheartbeat gryp$ vagrant ssh
```

## Cleanup

### Shutdown the vagrant instance

```
vagrant destroy -f
```

# PXC 

To install PXC, symlink Vagrant.pxc to Vagrant and do 'vagrant up --provider=aws'.  

Alternatively, you can launch and provision the instances in parallel with 'vagrant up --provider=aws --parallel'

After you have launched the instances, run './pxc-bootstrap.sh' in the root repository to finish the cluster bootstrap.

[Re-]provisioning in parallel:
```bash
vagrant provision node1 &
vagrant provision node2 &
vagrant provision node3
````


# Using this repo to create benchmarks

I use a system where I define this repo as a submodule in a test-specific git repo and do all the customization for the test there.



# Future Stuff

* Multi node coordination (need support from vagrant-aws)
 * Multi-AZ/Region coordination??
* CentOS support (pending packer merge: https://github.com/mitchellh/packer/pull/138)
* Virtualbox support
