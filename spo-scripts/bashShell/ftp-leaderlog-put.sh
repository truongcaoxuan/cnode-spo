#!/bin/bash
HOST=
USER=
PASSWORD=

pftp -inv $HOST <<EOF
user $USER $PASSWORD
lcd /home/USER/cardano-my-node
cd /domains/hwlegnano.it/public_html/status/
rename leaderlog.json leaderlog-previous.json
mput leaderlog.json
bye
EOF
