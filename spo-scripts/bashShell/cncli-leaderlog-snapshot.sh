#!/bin/bash

export CARDANO_NODE_SOCKET_PATH=/home/USER/cardano-node/db/socket

POOL=POOL_ID
SNAPSHOT=$(/usr/local/bin/cardano-cli query stake-snapshot --stake-pool-id $POOL --mainnet)
POOL_STAKE=$(jq .pools.$POOL.stakeMark <<< $SNAPSHOT)
ACTIVE_STAKE=$(jq .total.stakeMark <<< $SNAPSHOT)
/usr/local/bin/cncli leaderlog --pool-id $POOL --pool-vrf-skey /home/USER/cardano-node/vrf.skey --byron-genesis /home/USER/cardano-node/mainnet-byron-genesis.json --shelley-genesis /home/USER/cardano-node/mainnet-shelley-genesis.json --pool-stake $POOL_STAKE --active-stake $ACTIVE_STAKE --db /home/USER/cardano-node/scripts/cncli.db --tz Europe/Rome --consensus praos --ledger-set next > /home/USER/cardano-node/leaderlog.json
