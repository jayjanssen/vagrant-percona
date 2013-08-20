#!/bin/sh


# Bootstrap the cluster after 'vagrant up'.  This is required because we won't know the IPs of the nodes until then.

node1_ip=`vagrant ssh node1 -c "ip a l | grep eth0 | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`
echo "Node1's ip: $node1_ip";
node2_ip=`vagrant ssh node2 -c "ip a l | grep eth0 | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`
echo "Node2's ip: $node2_ip";
node3_ip=`vagrant ssh node3 -c "ip a l | grep eth0 | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`
echo "Node3's ip: $node3_ip";

wsrep_cluster_address="echo -e \"[mysqld]\n\nwsrep_cluster_address = gcomm://$node1_ip,$node2_ip,$node3_ip/\n\" > /etc/my-pxc.cnf"
echo $wsrep_cluster_address

vagrant ssh node1 -c "$wsrep_cluster_address"
vagrant ssh node2 -c "$wsrep_cluster_address"
vagrant ssh node3 -c "$wsrep_cluster_address"

# restart nodes2 and 3
vagrant ssh node2 -c "service mysql stop; rm /var/lib/mysql/grastate.dat; service mysql start"
vagrant ssh node3 -c "service mysql stop; rm /var/lib/mysql/grastate.dat; service mysql start"
