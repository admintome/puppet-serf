cd /tmp
sudo su <<EOF
mv /tmp/serf /usr/local/bin/serf
chmod a+x /usr/local/bin/serf
mv /tmp/serf.service /etc/systemd/system/serf.service
systemctl daemon-reload
systemctl start serf.service 
systemctl enable serf.service
EOF
