#!/bin/sh


# curl -s http://169.254.169.254/latest/meta-data/public-hostname | sed -re 's/[ tab]$//'

node_list=($(vagrant status | grep running | awk '{print $1}'))
node_ips=()

for (( i = 0 ; i < ${#node_list[@]} ; i++ ))
# for i in "${node_list[@]}" 
do    
    node=${node_list[$i]}
	get_ip_cmd="curl -s http://169.254.169.254/latest/meta-data/public-hostname"
    ip=`vagrant ssh $node -c "$get_ip_cmd" 2>/dev/null | grep -o '.*\.amazonaws\.com'`
    echo "$node: '$ip'"
done