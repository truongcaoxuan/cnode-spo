#!/bin/bash
# https://docs.cardano.org/learn/cardano-keys
# Operator/operational keys
# KES(Key Evolving Signature) keys
# VRF(Verifiable Random Function) keys

# air-gapped #####################################################
# the node operator's offline key is a cryptographic key used to secure and manage a node on the Cardano blockchain, 
# it is stored offline to protect it from being stolen or compromised, 
# it is used to sign transactions and perform other actions on the node.

# The cold verification key is a public key that is used to identify a specific node on the network. 
# The cold signing key is the corresponding private key that is used by the node to sign messages and other communications. 
# The node counter (node.counter) is a value that is incremented each time the node signs a message. 
# It is used to prevent replay attacks and to ensure that messages are processed in the correct order.
# A replay attack is a type of network attack in which an attacker intercepts and re-transmits a valid message (or transaction) in order to disrupt a target's normal activities or gain unauthorized access.
cardano-cli node key-gen \
    --cold-verification-key-file ${NODE_COLD}/cold.vkey \
    --cold-signing-key-file ${NODE_COLD}/cold.skey \
    --operational-certificate-issue-counter ${NODE_COLD}/node.counter

# producer ########################################################
# KES keys are implemented using a technique called "key evolution," 
# which allows for the generation of new keys while still maintaining the security of the previous keys.
# By using KES, the Cardano blockchain can ensure that the keys are rotated regularly, which helps to maintain the security of the network, 
# and to ensure that the keys are kept secret and protected from unauthorized access.

# The KES verification key is a public key that is used to verify that a given digital signature was created using the corresponding private KES signing key
# The KES signing key is used to secure the communication between the nodes in the network, and to ensure that only authorized parties can participate in the consensus process. 
cardano-cli node key-gen-KES \
    --verification-key-file ${NODE_HOT}/kes.vkey \
    --signing-key-file ${NODE_HOT}/kes.skey

# producer ########################################################
# VRF is used to select the next block producer, also known as the slot leader.

# The VRF verification key is a public key that is used to verify that a given VRF output (random value) was generated using the corresponding private VRF signing key.
# The VRF signing key is a private key that is used to generate a VRF output which is truly random and cannot be predicted or manipulated by any party.
cardano-cli node key-gen-VRF \
    --verification-key-file ${NODE_HOT}/vrf.vkey \
    --signing-key-file ${NODE_HOT}/vrf.skey
chmod 400 ${NODE_HOT}/vrf.skey

# producer ########################################################
# Block: a block is a collection of transactions that have been verified and added to the blockchain. 
# Each block contains a list of transactions, a reference to the previous block (also known as the "parent block"), and other information such as a timestamp and a block number.

# Slot: a unit of time in the Cardano blockchain.
# Each slot represents an opportunity for a slot leader to create a new block and add it to the blockchain. 
# The slot leader is chosen by a consensus protocol.

# Epoch: a period of time in the Cardano blockchain that is divided into a number of slots. 
# An epoch is a predefined period of time, during which a specific set of rules and parameters are in effect. 
# The duration of an epoch is defined in the Cardano protocol and it's usually around 5 days, it can also be adjusted by protocol updates.

# the number of slots per KES period from the genesis file.
slotsPerKESPeriod=$(cat ${NODE_ENVIRON}/shelley-genesis.json | jq -r '.slotsPerKESPeriod')
# Current slot number
slotNo=$(cardano-cli query tip ${NODE_NETWORK} | jq -r '.slot')
# how many KES period have passed since the genesis of the blockchain
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))

# air-gapped #####################################################
# generate an operational certificate for a node on the Cardano blockchain. 
# An operational certificate is a digital certificate that is used to prove the identity of a node and to authorize it to participate in the consensus process.
cardano-cli node issue-op-cert \
    --kes-verification-key-file ${NODE_HOT}/kes.vkey \
    --cold-signing-key-file ${NODE_COLD}/cold.skey \
    --operational-certificate-issue-counter ${NODE_COLD}/node.counter \
    --kes-period ${kesPeriod} \
    --out-file ${NODE_HOT}/node.cert

# producer ########################################################
sudo systemctl stop cardano-node

PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY=${NODE_ENVIRON}/topology.json
DB_PATH=${NODE_HOME}/db
SOCKET_PATH=${NODE_HOME}/db/socket
CONFIG=${NODE_ENVIRON}/config.json
KES=${NODE_HOT}/kes.skey
VRF=${NODE_HOT}/vrf.skey
CERT=${NODE_HOT}/node.cert
cat > ${NODE_HOME}/startCardanoNode.sh << EOF 
/usr/local/bin/cardano-node run +RTS -N -A16m -qg -qb -RTS \\
    --topology "${TOPOLOGY}" \\
    --database-path "${DB_PATH}" \\
    --socket-path "${SOCKET_PATH}" \\
    --host-addr "${HOSTADDR}" \\
    --port "${PORT}" \\
    --config "${CONFIG}" \\
    --shelley-kes-key "${KES}" \\
    --shelley-vrf-key "${VRF}" \\
    --shelley-operational-certificate "${CERT}"
EOF

sudo systemctl start cardano-node