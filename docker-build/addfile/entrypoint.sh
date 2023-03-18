#!/bin/bash

trap 'killall -s SIGTERM cardano-node' SIGINT SIGTERM
# "docker run --init" to enable the docker init proxy
# To manually test: docker kill -s SIGTERM container

#-- Show banner
head -n 15 ~/.scripts/banner.txt
#-- bashrc
. ~/.bashrc > /dev/null 2>&1
#-- Show node info
dbsize=$(du -s ${CNODE_HOME}/db | awk '{print $1}')

echo "NETWORK: $NETWORK $POOL_NAME";

[[ -z "${CNODE_HOME}" ]] && export CNODE_HOME=/opt/cardano/cnode 
[[ -z "${CNODE_PORT}" ]] && export CNODE_PORT=6000

echo "NODE: $HOSTNAME - DefaultPort:$CNODE_PORT - $POOL_NAME";
echo "db-size: $dbsize";
cardano-node --version;

#-- run cron
sudo /etc/init.d/cron start > /dev/null 2>&1

#-- run telnet
sudo /usr/sbin/inetd start > /dev/null 2>&1

#-- run node exporter
#/usr/bin/nohup /usr/local/bin/node_exporter --web.listen-address="0.0.0.0:9100" > /dev/null 2>&1 &

#-- sendmytip
#/usr/bin/nohup ~/.scripts/sendmytip.sh > /dev/null 2>&1 &

# blin EKG Prometheus
find /opt/cardano/cnode -name "*config*.json" -print0 | xargs -0 sed -i 's/127.0.0.1/0.0.0.0/g' 2> /dev/null 

# run node
~/.scripts/start_all.sh

# set TraceMempool false
#find /opt/cardano/cnode -name "*config*.json" -print0 | xargs -0 sed -i 's/\"TraceMempool\": true/\"TraceMempool\": false/g' 2> /dev/null 

/bin/bash
