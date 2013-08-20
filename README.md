# Vagrant + AWS + Percona Server

## Walkthrough
### AWS Setup

Need AWS setup with the following information in a file called ~/.aws_secrets:

```yaml
access_key_id: YOUR_ACCESS_KEY
secret_access_key: THE_ASSOCIATED_SECRET_KEY
keypair_name: KEYPAIR_ID
keypair_path: PATH_TO_KEYPAIR_PEM
```

ALSO put your access and secret keys in environment variables in your .bashrc or similar (for packer):

```bash
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=THE_ASSOCIATED_SECRET_KEY
```

### Software Requirements

* Vagrant 1.2+: http://vagrantup.com
* Packer 0.1.4+: http://packer.io
* Vagrant AWS Plugin:

```
 vagrant plugin install vagrant-aws
```

### Create your own AMI with an associated Vagrant box

* Modify packer/ubuntu.json 
 * Source AMI
 * Region

```bash
cd packer
packer validate ubuntu.json
packer build ubuntu.json
vagrant box add ubuntu-aws-us-east packer__aws.box
cd ..
```

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

### Packer AMIs

Packer creates an AMI on your AWS account, so you need to clean it up so you don't need to pay for it.

* AWS Console -> Images -> AMIs -> Select AMI -> Actions -> Deregister
* AWS Console -> Elastic Block Store -> Snapshots -> Select Snapshot -> Delete


### Vagrant EBS volumes

* AWS Console -> Elastic Block Store -> Volumes -> Select Volumes -> Actions -> Delete Volume

# PXC 

To install PXC, symlink Vagrantfile to Vagrantfile.pxc and do 'vagrant up --provider=aws'.  Alternatively, you can launch and provision the instances in parallel like this:

```bash
vagrant up node1 --provider=aws &
vagrant up node2 --provider=aws &
vagrant up node3 --provider=aws

./bootstrap.sh
````

# Future Stuff

* Multi node coordination (need support from vagrant-aws)
 * Multi-AZ/Region coordination??
* CentOS support (pending packer merge: https://github.com/mitchellh/packer/pull/138)
* Virtualbox support