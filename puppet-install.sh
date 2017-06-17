cd /tmp
wget -q https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo su <<EOF
echo "IP: $1"
echo "$1	 puppet.openstacklocal    puppet" >> /etc/hosts
cat /etc/hosts
dpkg -i puppetlabs-release-pc1-xenial.deb
apt update -y
apt install -y puppetserver
printf '*.openstacklocal\n*' > /etc/puppetlabs/puppet/autosign.conf
systemctl start puppetserver
cp /tmp/site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
echo "Puppet Server Installed"
EOF
