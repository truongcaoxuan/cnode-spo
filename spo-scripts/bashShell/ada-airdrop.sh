#!/usr/bin/env bash

DELEGATORS=$(curl -s https://cardano-mainnet.blockfrost.io/api/v0/pools/de2e00a923f6dd016a43087e608df9b6ddd4e587e8ff4f39c64e2d43/delegators -H 'project_id: ID')
drop1=150000000
drop2=900000000
poolid=\"pool1mchqp2fr7mwsz6jrpplxpr0ekmwafev8arl57wwxfck5x0dwv60\"

for row in $(echo "${DELEGATORS}" | jq -r '.[] | @base64'); do

    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

mysql -u USER -D SCHEMA -h HOST -N -e "UPDATE TABLE SET adaStaked = $(echo $(_jq '.live_stake')) WHERE stakeAddress = '$(echo $(_jq '.address'))';"

db_stake=$(mysql -u USER -D SCHEMA -h HOST -N -e "select adaStaked from TABLE where stakeAddress='$(echo $(_jq '.address'))';")

if (( db_stake >= drop1 ))
then

mysql -u USER -D SCHEMA -h HOST -N -e "UPDATE TABLE SET drop1 = 1 WHERE stakeAddress = '$(echo $(_jq '.address'))';"

else

mysql -u USER -D SCHEMA -h HOST -N -e "UPDATE TABLE SET drop1 = 0 WHERE stakeAddress = '$(echo $(_jq '.address'))';"

fi

if (( db_stake >= drop2 ))
then

mysql -u USER -D SCHEMA -h HOST -N -e "UPDATE TABLE SET drop2 = 1 WHERE stakeAddress = '$(echo $(_jq '.address'))';"

else

mysql -u USER -D SCHEMA -h HOST -N -e "UPDATE TABLE SET drop2 = 0 WHERE stakeAddress = '$(echo $(_jq '.address'))';"

fi

done

### DELETE NON-DELEG ###

delegs=($(mysql -u USER -D SCHEMA -h HOST -N -e "select stakeAddress from hwlairdrop;"))
cnt=${#delegs[@]}


for (( i=0 ; i<${cnt} ; i++ ))
do

poolfetch=$(curl -s https://cardano-mainnet.blockfrost.io/api/v0/accounts/{${delegs[$i]}} -H 'project_id: ID' | jq '.pool_id')

if [ "$poolfetch" != "$poolid" ]
then


mysql -u USER -D SCHEMA -h HOST -N -e "DELETE FROM TABLE WHERE stakeAddress = '${delegs[$i]}';"

fi
done

### TXs EXPORT ###

curl http://127.0.0.1:8090/v2/wallets/WALLETID/transactions | jq '[.[] | select((.amount.quantity>=50000000 and .amount.quantity<=51000000) or (.amount.quantity>=100000000 and .amount.quantity<=101000000))]' > /home/username/cardano-node/txs.json

### BACKUP DB ###

mysqldump -u USER -h HOST SCHEMA > /home/username/cardano-node/airdb.sql
