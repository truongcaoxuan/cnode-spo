#!/usr/bin/env bash
 
export CNODE_HOME=/opt/cardano/cnode

curl -s -k -o /tmp/vnpip_topology2.json "https://api.clio.one/htopology/v1/fetch/?max=20"

cat /tmp/vnpip_topology2.json | awk '{print $3,$5}' | tail -n +2 | sed s/"\","//g  | sed s/"\""//g | sed s/","//g | grep -v [a-z] >  /tmp/vnpip_list1              

IFS=$'\n'; for i in $(cat /tmp/vnpip_list1 ); do tcpping -x 1 $i | grep ms | awk '{print $9,$7}' >> /tmp/vnpip_list2 ; done
cat /tmp/vnpip_list2 | sort -n | grep -v "ms" | head -n 8 | cut -d "(" -f 2 | cut -d ")" -f 1   > /tmp/fastest_vnpip.list
 
IFS=$'\n'; for i in $(cat /tmp/fastest_vnpip.list); do  cat /tmp/vnpip_list1 | grep "$i" >> /tmp/vnpip_list3; done


VNPIP1=$(sed -n 1p /tmp/vnpip_list3 | awk '{print $1}')
VNPIP1PORT=$(sed -n 1p /tmp/vnpip_list3 | awk '{print $2}')
VNPIP2=$(sed -n 2p /tmp/guild_list3 | awk '{print $1}')
VNPIP2PORT=$(sed -n 2p /tmp/vnpip_list3 | awk '{print $2}')
VNPIP3=$(sed -n 3p /tmp/vnpip_list3 | awk '{print $1}')
VNPIP3PORT=$(sed -n 3p /tmp/vnpip_list3 | awk '{print $2}')
VNPIP4=$(sed -n 4p /tmp/vnpip_list3 | awk '{print $1}')
VNPIP4PORT=$(sed -n 4p /tmp/vnpip_list3 | awk '{print $2}')
VNPIP5=$(sed -n 5p /tmp/vnpip_list3 | awk '{print $1}')
VNPIP5PORT=$(sed -n 5p /tmp/vnpip_list3 | awk '{print $2}')
VNPIP6=$(sed -n 6p /tmp/vnpip_list3 | awk '{print $1}')
VNPIP6PORT=$(sed -n 6p /tmp/vnpip_list3 | awk '{print $2}')
VNPIP7=$(sed -n 7p /tmp/vnpip_list3 | awk '{print $1}')
VNPIP7PORT=$(sed -n 7p /tmp/vnpip_list3 | awk '{print $2}')
VNPIP8=$(sed -n 8p /tmp/vnpip_list3 | awk '{print $1}')
VNPIP8PORT=$(sed -n 8p /tmp/vnpip_list3 | awk '{print $2}')

cat <<EOF > $CNODE_HOME/files/topology.json
{ "resultcode": "201", "networkMagic": "764824073", "ipType":4, "Producers": [
  { "addr": "relays-new.cardano-mainnet.iohk.io", "port": 3001, "valency": 2, "distance":10 },
  { "addr": "$VNPIP1", "port": $VNPIP1PORT, "valency": 1, "distance":10 },
  { "addr": "$VNPIP2", "port": $VNPIP2PORT, "valency": 1, "distance":10 },
  { "addr": "$VNPIP3", "port": $VNPIP3PORT, "valency": 1, "distance":10 },
  { "addr": "$VNPIP4", "port": $VNPIP4PORT, "valency": 1, "distance":10 },
  { "addr": "$VNPIP5", "port": $VNPIP5PORT, "valency": 1, "distance":10 },
  { "addr": "$VNPIP6", "port": $VNPIP6PORT, "valency": 1, "distance":10 },
  { "addr": "$VNPIP7", "port": $VNPIP7PORT, "valency": 1, "distance":10 },
  { "addr": "$VNPIP8", "port": $VNPIP8PORT, "valency": 1, "distance":10 }
] }
EOF

rm  /tmp/fastest_vnpip.list && rm /tmp/vnpip_list*
