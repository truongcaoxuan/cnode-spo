#!/bin/bash
######################################
# User Variables - Change as desired #
# Leave as is if unsure              #
######################################
DATA_DIR="/tmp"                      # Folder where your data leadership schedule will be sent to


######################################
# Do NOT modify code below           #
######################################

#######################################################
# Get poolTicker list                                 #
#######################################################
printf -- '-%.0s' {1..50}; printf '\n'
poolTicker=$(cat /opt/cardano/cnode/files/pool-list.json | jq -r 'keys[]')
echo "Ticker list:"
echo "${poolTicker}"

#######################################################
# Get number poolTicker                               #
#######################################################
printf -- '-%.0s' {1..50}; printf '\n'
totalPool=$(echo -n "${poolTicker}" | grep -c '^')
echo "Total Pool Ticker: ${totalPool}"

#######################################################
# Get current Date                                    #
#######################################################
printf -- '-%.0s' {1..50}; printf '\n'
currentDate=$(TZ="Asia/Ho_Chi_Minh" date +"%A, %d/%m/%Y %H:%M")
echo "Current Date and Time is: " 
echo "${currentDate}"
echo "${currentDate}" > "${DATA_DIR}/data-leadership.txt"

#######################################################
# Chose mainnet/testnet parameters                    #
#######################################################
printf -- '-%.0s' {1..50}; printf '\n'
net="--mainnet"
read -p "Enter network 1=mainnet, 2=testnet (other=default=1): " NET
if [[ "$NET" == "2" ]]; then
    net="--testnet-magic 42"
    echo "Check leadership-schedule for ${net}"
else
    echo "Check leadership-schedule for ${net}"
fi

#######################################################
# Chose the epoch parameters                          #
#######################################################
printf -- '-%.0s' {1..50}; printf '\n'
epoch="--next"
read -p "Enter Epoch 1=next, 2=current (other=default=1): " EPOCH
if [[ "$EPOCH" == "2" ]]; then
    epoch="--current"
    echo "Check leadership-schedule for ${epoch}"
else
    echo "Check leadership-schedule for ${epoch}"
fi

#######################################################
# Processing check leadership-schedule                #
#######################################################
printf -- '-%.0s' {1..50}; printf '\n'
i=0
for poolName in ${poolTicker}
do
  let "i++"
  echo "[${i}/${totalPool}] Start check leadership-schedule for ${poolName} pool" 
  
  poolID=$(cat /opt/cardano/cnode/files/pool-list.json | jq -r .${poolName})
  echo "${poolID}"
  
  if [[ -z ${poolID} ]]; then
    echo "poolID not found for ${poolName} !!!"
    let "i--"
  else
    echo "${poolName} leadership-schedule processing" 
    echo "${poolName} leadership-schedule" >> "${DATA_DIR}/data-leadership.txt"
    cardano-cli query leadership-schedule \
     "${net}" \
     --genesis /opt/cardano/cnode/files/shelley-genesis.json \
     --stake-pool-id  "${poolID}" \
     --vrf-signing-key-file "/opt/cardano/cnode/priv/pool/${poolName}/vrf.skey" \
     "${epoch}" | tee -a "${DATA_DIR}/data-leadership.txt"
    printf '.[-].%.0s' {1..15}; printf '\n' 
    echo "Check leadership-schedule for ${poolName} finished "
    printf '*%.0s' {1..50}; printf '\n'
    
  fi
done

printf -- '-%.0s' {1..50}; printf '\n'
#######################################################
# Notify the result                                   #
#######################################################
echo " Result: [${i}/${totalPool}] SUCCESS! "
