#!/bin/sh

set -e

type=$1
destdir=$2
pwd=`pwd`
infofile=$destdir/vagrant-percona-info


if [ $# -ne 2 ]; then
	echo "Usage $0 (ebs_custom|ms|pxc|pxc_multi_region|single_node) destinationdirectory"
	echo ""
	exit 1
fi

if [ -e $destdir ]; then
	echo "ERROR: the destination directory $destdir already exists, exiting..."
	echo ""
	exit 1
fi


case $type in
	ebs_custom|ms|pxc|pxc_multi_region|single_node)
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
cp Vagrantfile.$type $destdir/Vagrantfile
ln -s $pwd/lib $destdir/
ln -s $pwd/puppet $destdir/


cat << EOF > $infofile
SRCDIR=$pwd 
TYPE=$type
GITVERSION=`git log --pretty=format:'%h' -n 1`
EOF

case $type in
	ebs_custom)
	;;
	ms)
		cp ms-setup.pl $destdir/
	;;
	pxc)
		cp pxc-bootstrap.sh $destdir/
	;;
	pxc_multi_region)
		cp pxc-bootstrap.sh $destdir/
	;;
	single_node)
	;;
esac

cd $destdir