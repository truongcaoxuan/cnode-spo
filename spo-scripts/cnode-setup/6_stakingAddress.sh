#!/bin/bash

# air-gapped #####################################################
cardano-cli stake-address registration-certificate \
    --stake-verification-key-file ${NODE_COLD}/stake.vkey \
    --out-file ${NODE_HOT}/stake.cert

# producer ########################################################
cardano-cli query utxo \
    --address $(cat ${NODE_HOT}/payment.addr) \
    ${NODE_NETWORK} > ${NODE_TMP}/fullUtxo.out
tail -n +3 ${NODE_TMP}/fullUtxo.out | sort -k3 -nr > ${NODE_TMP}/balance.out
tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < ${NODE_TMP}/balance.out
txcnt=$(cat ${NODE_TMP}/balance.out | wc -l)

# stakeAddressDeposit: minimum deposit required to register a new stake pool on the Cardano blockchain
stakeAddressDeposit=$(cat ${NODE_ENVIRON}/params.json | jq -r '.stakeAddressDeposit')
currentSlot=$(cardano-cli query tip ${NODE_NETWORK} | jq -r '.slot')
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat ${NODE_HOT}/payment.addr)+0 \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee 0 \
    --certificate ${NODE_HOT}/stake.cert \
    --out-file ${NODE_TMP}/tx.raw
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file ${NODE_TMP}/tx.raw \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --witness-count 2 \
    ${NODE_NETWORK} \
    --protocol-params-file ${NODE_ENVIRON}/params.json | awk '{ print $1 }')
txOut=$((${total_balance}-${stakeAddressDeposit}-${fee}))
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat ${NODE_HOT}/payment.addr)+${txOut} \
    --invalid-hereafter $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file ${NODE_HOT}/stake.cert \
    --out-file ${NODE_TMP}/tx.raw

# air-gapped #####################################################
cardano-cli transaction sign \
    --signing-key-file ${NODE_COLD}/payment.skey \
    --signing-key-file ${NODE_COLD}/stake.skey \
    --tx-body-file ${NODE_TMP}/tx.raw \
    ${NODE_NETWORK} \
    --out-file ${NODE_TMP}/tx.signed

# producer ########################################################
cardano-cli transaction submit \
    --tx-file ${NODE_TMP}/tx.signed \
    ${NODE_NETWORK}