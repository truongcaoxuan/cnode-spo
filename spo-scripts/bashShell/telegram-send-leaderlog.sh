#!/usr/bin/env bash

EPOCH=$(curl LEADERLOG.JSON | jq -r '.epoch')
LEADER_AT=$(curl LEADERLOG.JSON | jq -r '.assignedSlots[].at')
EXPECTED=$(curl LEADERLOG.JSON | jq -r '.epochSlotsIdeal')
LUCK=$(curl LEADERLOG.JSON | jq -r '.maxPerformance')

if test -z "$LEADER_AT" 
then

curl -X POST \
   -H 'Content-Type: application/json' \
   -d '{"chat_id": "CHAT_ID", "text": "<b>LEADERLOG CALCULATION AND SCHEDULE</b>\n\n<b>EPOCH:</b> '$EPOCH'\n\n<b>Slots expected:</b> '$EXPECTED'\n<b>Maximum Luck:</b> '$LUCK' %\n\n<b>Slots assigned:</b>\n\nNONE FOR THIS EPOCH &#128532;", "disable_notification": true, "parse_mode": "HTML"}' \
   https://api.telegram.org/botAPIKEY/sendMessage

else

LEADER_LB=$(echo "${LEADER_AT//$'\n'/\\n}")
LEADER_LINES=$(echo -e "$LEADER_LB" | wc -l)

curl -X POST \
   -H 'Content-Type: application/json' \
   -d '{"chat_id": "CHAT_ID", "text": "<b>LEADERLOG CALCULATION AND SCHEDULE</b>\n\n<b>EPOCH:</b> '$EPOCH'\n\n<b>Slots expected:</b> '$EXPECTED'\n<b>Maximum Luck:</b> '$LUCK' %\n\n<b>Slots assigned: ('$LEADER_LINES') &#128512;</b>\n", "disable_notification": true, "parse_mode": "HTML"}' \
   https://api.telegram.org/botAPIKEY/sendMessage


fi
