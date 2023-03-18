#!/bin/bash

cardano-node +RTS -N -RTS run \
--config /opt/cardano/config/mainnet-config.json \
--topology /opt/cardano/config/mainnet-topology.json \
--database-path /opt/cardano/data \
--socket-path /opt/cardano/ipc/socket \
--host-addr 0.0.0.0 \
--port 3001
#--shelley-vrf-key /opt/cardano/priv/pool/TRADA/vrf.skey \
#--shelley-kes-key /opt/cardano/priv/pool/TRADA/hot.skey \
#--shelley-operational-certificate /opt/cardano/priv/pool/TRADA/op.cert
