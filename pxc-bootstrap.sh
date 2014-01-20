#!/bin/sh


# Bootstrap the cluster after 'vagrant up'.  This is required because we won't know the IPs of the nodes until then (on AWS).
nic='eth1'
using_aws=false
get_ip_cmd="ip -o -f inet addr show $nic | awk '{split(\$4,arr,\"/\"); print arr[1]}'"

if vagrant status | grep aws > /dev/null
then
	echo "AWS detected: using public hostnames"
	using_aws=true
	get_ip_cmd="curl -s http://169.254.169.254/latest/meta-data/public-hostname"
else
	echo "Assuming $nic is the Galera communication nic"
fi

node1_ip=`vagrant ssh node1 -c "$get_ip_cmd" | sed 's/.$//'`
echo "Node1: '$node1_ip'";
node2_ip=`vagrant ssh node2 -c "$get_ip_cmd" | sed 's/.$//'`
echo "Node2: '$node2_ip'";
node3_ip=`vagrant ssh node3 -c "$get_ip_cmd" | sed 's/.$//'`
echo "Node3: '$node3_ip'";


echo "Adding configuration to /etc/my-pxc.cnf on all nodes"
wsrep_cluster_address="echo -e \"[mysqld]\n\nwsrep_cluster_address = gcomm://$node1_ip,$node2_ip,$node3_ip\n\" > /etc/my-pxc.cnf"

vagrant ssh node1 -c "$wsrep_cluster_address"
vagrant ssh node2 -c "$wsrep_cluster_address"
vagrant ssh node3 -c "$wsrep_cluster_address"

if $using_aws
then
	# Set the SST and IST receive addresses too
	echo "AWS: setting SST and IST receive addresses"
	vagrant ssh node1 -c "echo -e \"wsrep_sst_receive_address = $node1_ip\n\" >> /etc/my-pxc.cnf"
	vagrant ssh node2 -c "echo -e \"wsrep_sst_receive_address = $node2_ip\n\" >> /etc/my-pxc.cnf"
	vagrant ssh node3 -c "echo -e \"wsrep_sst_receive_address = $node3_ip\n\" >> /etc/my-pxc.cnf"

	vagrant ssh node1 -c "grep wsrep_provider_options /etc/my.cnf | sed 's/\"$/; ist.recv_addr=$node1_ip\"/' >> /etc/my-pxc.cnf"
	vagrant ssh node2 -c "grep wsrep_provider_options /etc/my.cnf | sed 's/\"$/; ist.recv_addr=$node2_ip\"/' >> /etc/my-pxc.cnf"
	vagrant ssh node3 -c "grep wsrep_provider_options /etc/my.cnf | sed 's/\"$/; ist.recv_addr=$node3_ip\"/' >> /etc/my-pxc.cnf"
	
else
	# Set the wsrep_node_address too
	echo "Setting wsrep_node_address"
	vagrant ssh node1 -c "echo -e \"wsrep_node_address = $node1_ip\n\" >> /etc/my-pxc.cnf"
	vagrant ssh node2 -c "echo -e \"wsrep_node_address = $node2_ip\n\" >> /etc/my-pxc.cnf"
	vagrant ssh node3 -c "echo -e \"wsrep_node_address = $node3_ip\n\" >> /etc/my-pxc.cnf"
fi


vagrant ssh node1 -c "service mysql stop; service mysql bootstrap-pxc"
# Setup SST user on node1
vagrant ssh node1 -c "mysql -e \"GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sst'@'localhost' IDENTIFIED BY 'secret'\""

# restart nodes2 and 3
vagrant ssh node2 -c "service mysql stop; rm /var/lib/mysql/grastate.dat"
vagrant ssh node3 -c "service mysql stop; rm /var/lib/mysql/grastate.dat"

vagrant ssh node2 -c "service mysql start"
vagrant ssh node3 -c "service mysql start"
