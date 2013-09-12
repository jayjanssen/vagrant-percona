#!/bin/sh


# Bootstrap the cluster after 'vagrant up'.  This is required because we won't know the IPs of the nodes until then (on AWS).
nic='eth1'
using_aws=false
if vagrant status | grep aws > /dev/null
then
	using_aws=true
	nic='eth0'
fi

echo "Assuming $nic is the Galera communication nic"


node1_ip=`vagrant ssh node1 -c "ip a l | grep $nic | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`
echo "Node1's ip: $node1_ip";
node2_ip=`vagrant ssh node2 -c "ip a l | grep $nic | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`
echo "Node2's ip: $node2_ip";
node3_ip=`vagrant ssh node3 -c "ip a l | grep $nic | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`
echo "Node3's ip: $node3_ip";

wsrep_cluster_address="echo -e \"[mysqld]\n\nwsrep_cluster_address = gcomm://$node1_ip,$node2_ip,$node3_ip\n\" > /etc/my-pxc.cnf"
echo $wsrep_cluster_address

vagrant ssh node1 -c "$wsrep_cluster_address"
vagrant ssh node2 -c "$wsrep_cluster_address"
vagrant ssh node3 -c "$wsrep_cluster_address"

if ! $using_aws
then
	# Set the wsrep_node_address too
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
