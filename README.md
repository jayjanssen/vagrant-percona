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


## Cleanup

### Shutdown the vagrant instance

```
vagrant destroy -f
```

# PXC 

To install PXC, symlink Vagrantfile to Vagrantfile.pxc and do 'vagrant up --provider=aws'.  Alternatively, you can launch and provision the instances in parallel like this:

```bash
vagrant up node1 --provider=aws &
vagrant up node2 --provider=aws &
vagrant up node3 --provider=aws

./bootstrap.sh
````

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