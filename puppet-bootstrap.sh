#!/bin/bash

sudo su <<EOF
echo "$1	puppet" >> /etc/hosts
echo "$2	$3" >> /etc/hosts
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install puppet-agent unzip -y
/opt/puppetlabs/bin/puppet agent --test
echo "First Puppet Run Complete"
/opt/puppetlabs/bin/puppet agent --test
echo "Second Puppet Run Complete"
EOF

