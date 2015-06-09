#!/bin/sh

set -e

type=$1
destdir=$2
pwd=`pwd`
infofile=$destdir/vagrant-percona-info

types="ec2_provisioned_iops|ms|mysql57|pxc|ps_sysbench|pxc_playground"

if [ $# -ne 2 ]; then
	echo "Usage $0 ($types) destinationdirectory"
	echo ""
	exit 1
fi

if [ -e $destdir ]; then
	echo "ERROR: the destination directory $destdir already exists, exiting..."
	echo ""
	exit 1
fi


case $type in
	ec2_provisioned_iops|ms|mysql57|pxc|ps_sysbench|pxc_playground)
		echo "Creating '$type' Environment"
	;;
	*)
	echo "ERROR: Invalid type $type given, exiting..."
	echo ""
	exit 1
	;;
esac

mkdir -p $destdir

# For every type, we need these
cp Vagrantfile.$type.rb $destdir/Vagrantfile

cp -R $pwd $destdir/vagrant-percona/
ln -s vagrant-percona/lib $destdir/
ln -s vagrant-percona/modules $destdir/
ln -s vagrant-percona/manifests $destdir/


cat << EOF > $infofile
SRCDIR=$pwd 
TYPE=$type
GITVERSION=`git log --pretty=format:'%h' -n 1`
EOF

case $type in
	ebs_custom)
	;;
	ms)
		ln -s $pwd/ms-setup.pl $destdir/
	;;
	pxc)
		ln -s $pwd/pxc-bootstrap.sh $destdir/
	;;
	pxc_multi_region)
		ln -s $pwd/pxc-bootstrap.sh $destdir/
	;;
	single_node)
	;;
esac

cd $destdir
