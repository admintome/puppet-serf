[Unit]
Description=Serf
Documentation=https://www.serf.io/docs/

[Service]
ExecStart=/usr/local/bin/serf agent -node=%H -iface=eth0 -join=${serf_server_ip} -event-handler=/etc/serf/handler.sh
ExecStartPost=/usr/local/bin/serf tags -set fqdn=%H
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target