#!/bin/sh


# curl -s http://169.254.169.254/latest/meta-data/public-hostname | sed -re 's/[ tab]$//'

node_list=($(vagrant status | grep running | awk '{print $1}'))
node_ips=()
# Bootstrap the cluster after 'vagrant up'.  This is required because we won't know the IPs of the nodes until then (on AWS).
nic='eth1'
using_aws=false

if vagrant status | grep aws > /dev/null
then
	echo "AWS detected: using public hostnames"
	using_aws=true
else
	echo "Assuming $nic is the Galera communication nic"
fi

for (( i = 0 ; i < ${#node_list[@]} ; i++ ))
# for i in "${node_list[@]}" 
do    
    node=${node_list[$i]}
    if $using_aws
    then
    	get_ip_cmd="curl -s http://169.254.169.254/latest/meta-data/public-hostname"
        ip=`vagrant ssh $node -c "$get_ip_cmd" | grep -o '.*\.amazonaws\.com'`
    else
        get_ip_cmd="ip -o -f inet addr show $nic | awk '{split(\$4,arr,\"/\"); print arr[1]}' |  perl -i -pe 's/[^\d\.]//g' "
        ip=`vagrant ssh $node -c "$get_ip_cmd"`
    fi
    echo "$node: '$ip'"
    node_ips[$i]=$ip
done

ip_string=$(printf ",%s" "${node_ips[@]}")
ip_string=${ip_string:1}

echo "Adding configuration to /etc/my-pxc.cnf on all nodes"
wsrep_cluster_address="echo -e \"[mysqld]\n\nwsrep_cluster_address = gcomm://$ip_string\n\" > /etc/my-pxc.cnf"

for (( i = 0 ; i < ${#node_list[@]} ; i++ ))
do
    node=${node_list[$i]}
    node_ip=${node_ips[$i]}
    vagrant ssh $node -c "$wsrep_cluster_address"

    if $using_aws
    then
	# Set the SST and IST receive addresses too
    	echo "AWS: setting SST and IST receive addresses"
    	vagrant ssh $node -c "echo -e \"wsrep_sst_receive_address = $node_ip\n\" >> /etc/my-pxc.cnf"
	
	    vagrant ssh $node -c "grep wsrep_provider_options /etc/my.cnf | sed 's/\"$/; ist.recv_addr=$node_ip\"/' >> /etc/my-pxc.cnf"
    else
    	# Set the wsrep_node_address too
    	echo "Setting wsrep_node_address"
    	vagrant ssh $node -c "echo -e \"wsrep_node_address = $node_ip\n\" >> /etc/my-pxc.cnf"
    fi
done


bootstrapped=false
for node in "${node_list[@]}" 
do
    if $bootstrapped
    then
        vagrant ssh $node -c "service mysql stop; rm /var/lib/mysql/grastate.dat"
        vagrant ssh $node -c "service mysql start"
    else
        vagrant ssh $node -c "service mysql stop; service mysql bootstrap-pxc"
        # Setup SST user on bootstrapped node
        vagrant ssh $node -c "mysql -e \"GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sst'@'localhost' IDENTIFIED BY 'secret'\""
        bootstrapped=true
    fi
    
done
