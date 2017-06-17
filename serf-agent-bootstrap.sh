cd /tmp
sudo su <<EOF
mkdir /etc/serf
mv /tmp/serf-dirs/* /etc/serf/
chmod a+x /etc/serf/handler.sh
mv /tmp/serf /usr/local/bin/serf
chmod a+x /usr/local/bin/serf
mv /tmp/runpuppet.sh /opt/runpuppet.sh
chmod a+x /opt/runpuppet.sh
mv /tmp/serf-agent.service /etc/systemd/system/serf-agent.service
systemctl daemon-reload
systemctl start serf-agent.service 
systemctl enable serf-agent.service
EOF
