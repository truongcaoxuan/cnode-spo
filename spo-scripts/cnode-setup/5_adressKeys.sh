#!/bin/bash

# producer ########################################################
# These parameters include things like the block size limit, fee per bytes.
cardano-cli query protocol-parameters \
    ${NODE_NETWORK} \
    --out-file ${NODE_ENVIRON}/params.json

# air-gapped #####################################################
# These keys can be used to send and receive transactions on the Cardano blockchain.
cardano-cli address key-gen \
    --verification-key-file ${NODE_COLD}/payment.vkey \
    --signing-key-file ${NODE_COLD}/payment.skey

# These keys used to stake ADA and participate in consensus
cardano-cli stake-address key-gen \
    --verification-key-file ${NODE_COLD}/stake.vkey \
    --signing-key-file ${NODE_COLD}/stake.skey

# A stake address is an address that holds ADA and is used to delegate stake to a stake pool.
cardano-cli stake-address build \
    --stake-verification-key-file ${NODE_COLD}/stake.vkey \
    --out-file ${NODE_HOT}/stake.addr \
    ${NODE_NETWORK}

cardano-cli address build \
    --payment-verification-key-file ${NODE_COLD}/payment.vkey \
    --stake-verification-key-file ${NODE_COLD}/stake.vkey \
    --out-file ${NODE_HOT}/payment.addr \
    ${NODE_NETWORK}


# producer ########################################################
# faucet: https://docs.cardano.org/cardano-testnet/tools/faucet
cardano-cli query utxo \
    --address $(cat ${NODE_HOT}/payment.addr) \
    ${NODE_NETWORK}