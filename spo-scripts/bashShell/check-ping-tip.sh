#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2086,SC2230,SC2009,SC2206,SC2062,SC2059
# Replace YOUR-USERNAME and YOUR-PING-ID below. You need a Healthcheck.io Account

CARDANO_CLI_PATH=                                       #Set the name which was used for Installing CNODE. - e.g. /home/YOUR-USERNAME/.cabal/bin/cardano-cli
                                                        #Make sure to replace YOUR-USER
HEALTHCHECKS_PING_URL=                                  #Copy and Paste the full Ping URL from Healthcheks.IO - e.g. https://hc-ping.com/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
ACCEPTED_TIP_DIFF=60                                    #How many seconds are OK before starting to not send OK signals to Healthcheks?

######################################
# Do NOT modify code below           #
######################################

export CARDANO_NODE_SOCKET_PATH=/opt/cardano/cnode/sockets/node0.socket

customCurrentSlotNoString=$($CARDANO_CLI_PATH query tip --mainnet | grep -Po '\"slot\": \K[0-9]+')
customCurrentSlotNo=$(expr $customCurrentSlotNoString + 0)

customRefSlotNo=$(expr $(printf '%(%s)T\n' -1) - 1591566291)
customDiff=$(expr $customRefSlotNo - $customCurrentSlotNo)

if [[ $customDiff -le $ACCEPTED_TIP_DIFF ]]
then
  echo "all good sending ping"
  curl -m 10 --retry 5 $HEALTHCHECKS_PING_URL
exit
fi