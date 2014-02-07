#!/usr/bin/perl

print "Setup nodes with replication\n";

# setup all nodes in replication with the first node in `vagrant status` as the master.

my @running_nodes_lines = `vagrant status | grep running`;
my @running_nodes;
foreach my $line( @running_nodes_lines ) {
	if( $line =~ m/^(\w+)\s+\w+\s+\((\w+)\)$/ ) {
		push( @running_nodes, {
			name => $1,
			provider => $2
		});
	}
}

# Harvest node ips
foreach my $node( @running_nodes ) {
	my $nic = 'eth1';
	$nic = 'eth0' if $node->{provider} eq 'aws';

	my $ip_str = `vagrant ssh $node->{name} -c "ip a l | grep $nic | grep inet"`;
	if( $ip_str =~ m/inet\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\// ) {
		$node->{ip} = $1;
	}
}

# use Data::Dumper qw( Dumper );
# print Dumper( @running_nodes );

my $master = shift @running_nodes;
my $master_ip = $master->{ip};

print "Master node will be: $master->{name}\n";

# Get Master binlog file and position
my $master_status =<<END;
mysql --batch -e \\"show master status\\" | tail -n 1
END
my @master_status_str = `vagrant ssh $master->{name} -c \"$master_status\"`;
my $master_log_file;
my $master_log_pos;
if( $master_status_str[$#master_status_str] =~ m/^(.+)\s+(\d+)/ ) {
	$master_log_file = $1;
	$master_log_pos = $2;
} else {
	die "Could not parse master log file and position!\n";
}

# Setup slave user:
print "Setting up 'repl' user on $master->{name}\n";
my $grant =<<END;
mysql -e \\"GRANT REPLICATION SLAVE ON *.* TO 'repl'\@'%' IDENTIFIED BY 'repl'\\"
END
system( "vagrant ssh $master->{name} -c \"$grant\"");

# Configure the slaves
print <<END;
Replication coordinates:
	master_host='$master_ip'
	master_log_file='$master_log_file'
	master_log_pos=$master_log_pos
END

my $change_master =<<END;
mysql -e \\"CHANGE MASTER TO master_host='$master_ip', master_log_file='$master_log_file', master_log_pos=$master_log_pos, master_user='repl', master_password='repl'; start slave;\\"
END
foreach my $slave( @running_nodes ) {
	print "Executing CHANGE MASTER on $slave->{name}\n";
	system( "vagrant ssh $slave->{name} -c \"$change_master\"");
}