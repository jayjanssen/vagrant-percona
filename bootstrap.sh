#!/bin/sh

# Bootstrap the cluster after 'vagrant up'.  This is required because we won't know the IPs of the nodes until then.

node1_ip=`vagrant ssh node1 -c "ip a l | grep eth0 | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`
node2_ip=`vagrant ssh node2 -c "ip a l | grep eth0 | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`
node3_ip=`vagrant ssh node3 -c "ip a l | grep eth0 | grep inet | awk '{print \\$2}' | awk -F/ '{print \\$1}'"`

wsrep_cluster_address="perl -pi -e 's/^wsrep_cluster_address.*$/wsrep_cluster_address = gcomm:\/\/$node1_ip,$node2_ip,$node3_ip/' /etc/my.cnf"
echo $wsrep_cluster_address

vagrant ssh node1 -c "$wsrep_cluster_address"
vagrant ssh node2 -c "$wsrep_cluster_address"
vagrant ssh node3 -c "$wsrep_cluster_address"

# restart nodes2 and 3
vagrant ssh node2 -c "service mysql restart"
