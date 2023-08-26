#!/bin/bash
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=${NODE_ENVIRON}/topology.json
DB_PATH=${NODE_HOME}/db
SOCKET_PATH=${NODE_HOME}/db/socket
CONFIG=${NODE_ENVIRON}/config.json
USER=root

cat << EOF > ${NODE_HOME}/startCardanoNode.sh
/usr/local/bin/cardano-node run \\
  --topology "${TOPOLOGY}" \\
  --database-path "${DB_PATH}" \\
  --socket-path "${SOCKET_PATH}" \\
  --host-addr "${HOSTADDR}" \\
  --port "${PORT}" \\
  --config "${CONFIG}"
EOF
chmod +x ${NODE_HOME}/startCardanoNode.sh
mkdir -p ${NODE_HOME}/db

sudo bash -c "cat << EOF > ${NODE_HOME}/cardano-node.service
[Unit]
Description       = Cardano Node Service
Wants             = network-online.target
After             = network-online.target  
  
[Service]
User              = ${USER}
ExecStart         = /bin/bash -c '${NODE_HOME}/startCardanoNode.sh'
Restart           = always
RestartSec        = 10
  
[Install]
WantedBy          = multi-user.target
EOF"

sudo mv ${NODE_HOME}/cardano-node.service /etc/systemd/system/cardano-node.service
sudo chmod 644 /etc/systemd/system/cardano-node.service

sudo systemctl daemon-reload
sudo systemctl enable cardano-node.service
sudo systemctl start cardano-node
sudo systemctl status cardano-node

# install gLiveView 
cd ${NODE_UTIL}

sudo apt install bc tcptraceroute -y
curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
chmod 755 gLiveView.sh

sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_ENVIRON}\/config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_ENVIRON}\/db\/socket\"/g"