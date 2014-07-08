# Vagrant + Percona 

## Introduction

This repository contains tools to build consistent environments for testing Percona software on a variety of platforms.  This includes EC2 and Virtualbox for now, but more are possible going forward.

Principles/goals of this environment:

* Extremely Reusable
* Small manifests to be used by multiple vagrant providers to combine components for needed boxes
* Vagrantfiles are very descriptive about the whole environment needed.  Preference given to making modules configurable rather than custom. 
* Useful for:
 * Conference tutorial environments
 * Training classes
 * Experimentation
 * Benchmarking
* Manifest install categories:
 * MySQL and variants
 * MySQL tools
 * Benchmarking tools
 * Sample databases
 * Misc: local repos for conference VMs, 


## Walkthrough

This section should get you up and running.

### Software Requirements

* Vagrant 1.6+: http://vagrantup.com
* Vagrant AWS Plugin (optional):

```
 vagrant plugin install vagrant-aws
```

* VirtualBox: https://www.virtualbox.org (optional)
* VMware Fusion (not supported yet, but feasible)


### AWS Setup

You can skip this section if you aren't planning on using AWS.  

In a nutshell, you need this:

* AWS access key
* AWS secret access key
* A Keypair name and path for each AWS region you intend to use
* Whatever security groups you'll need for the environments you intend to launch.

#### AWS Details

You'll need an AWS account setup with the following information in a file called ~/.aws_secrets:

```yaml
access_key_id: YOUR_ACCESS_KEY
secret_access_key: THE_ASSOCIATED_SECRET_KEY
keypair_name: KEYPAIR_ID
keypair_path: PATH_TO_KEYPAIR_PEM
instance_name_prefix: SOME_NAME_PREFIX
```


#### Multi-region

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

#### Boxes and multi-region

Note that the aws Vagrant boxes you use must include AMI's in each region.  For example, see the regions listed here: https://vagrantcloud.com/perconajayj/centos-x86_64.  Packer, which is used to build this box, can be configured to add more regions if desired, but it requires building a new box.  

### Clone this repo

```bash
git clone <clone URL> 
cd vagrant-percona
```

### Launch the box

Launch your first box -- ps_sysbench is a good start.  

```bash
ln -sf Vagrantfile.ps_sysbench.rb Vagrantfile
vagrant up
vagrant ssh
```

### Create Environments with create-new-env.sh

When you create a lot of vagrant environments with vagrant-percona, creating/renaming those Vagrantfile files can get quite messy easily.

The repository contains a small script that allows you to create a new environment, which will build a new directory with the proper Vagrantfile files and links to the puppet code. If you're setting up a PXC environment, symlinks will also be provided to the necessary pxc-bootstrap.sh script.

This allows you to have many many Vagrant environments configured simultaneously.

```bash
vagrant-percona$ ./create-new-env.sh single_node ~/vagrant/percona-toolkit-ptosc-plugin-ptheartbeat
Creating 'single_node' Environment

percona-toolkit-ptosc-plugin-ptheartbeat gryp$ vagrant up --provider=aws
percona-toolkit-ptosc-plugin-ptheartbeat gryp$ vagrant ssh
```

## Cleanup

### Shutdown the vagrant instance(s)

```
vagrant destroy
```

## Master/Slave

```bash
ln -sf Vagrantfile.ms.rb Vagrantfile
vagrant up 
./ms-setup.pl
```  

## PXC 

```bash
ln -sf Vagrantfile.pxc.rb Vagrantfile
vagrant up
./pxc-bootstrap.sh
```  


## Using this repo to create benchmarks

I use a system where I define this repo as a submodule in a test-specific git repo and do all the customization for the test there.

```bash
git init some-test
cd some-test
git submodule add git@github.com:jayjanssen/vagrant-percona.git
ln -s vagrant-percona/lib
ln -s vagrant-percona/manifests
ln -s vagrant-percona/modules
cp vagrant-percona/Vagrantfile.of_your_choice Vagrantfile
vi Vagrantfile  # customize for your test
vagrant up
...
```

# Future Stuff


* Virtualbox support
