#!/bin/bash
#Show Peer IN Number
echo "======================"
echo "Total Peer IN"
echo $(ss -tnp state established 2>/dev/null | \
       grep "$(pgrep -fn "[c]ardano-node*.*--port 6000")," | \
       grep -v ":$(ss -tnp state established "( dport = :6000 )" 2>/dev/null | \
       grep cncli | awk '{print $3}' | cut -d: -f2) " | \
       awk -v port=":6000" '$3 ~ port {print}' | wc -l)
# Get Peer IN IP and Port
peers=$(ss -tnp state established 2>/dev/null | \
        grep "$(pgrep -fn "[c]ardano-node*.*--port 6000")," | \
        grep -v ":$(ss -tnp state established "( dport = :6000} )" 2>/dev/null | \
        grep cncli | awk '{print $3}' | cut -d: -f2) " | \
        awk -v port=":6000" '$3 ~ port {print $4}')
netstatSorted=$(printf '%s\n' "${peers[@]}" | sort)
echo "======================"
echo "Peer IN list"
echo $netstatSorted
echo "======================"
echo "Check RTT Ping ICMP for each IP"
lastpeerIP=""
for peer in ${netstatSorted}; do
    peerIP=$(echo "${peer}" | cut -d: -f1)
    peerIP2=$(printf '%s' "${peerIP}")
    echo $peerIP2
    #echo $(ping -c 2 -i 0.3 -w 1 "${peerIP}" 2>&1 | tail -n 1 | cut -d/ -f5 | cut -d. -f1)
    if checkPEER=$(ping -c 2 -i 0.3 -w 1 "${peerIP}" 2>&1); then # Incoming connection, ping OK, show RTT.
      echo "Incoming connection, ping OK, show RTT"
      #peerRTT=$(echo "${checkPEER}" | tail -n 1 | cut -d/ -f5 | cut -d. -f1)
      echo $(ping -c 2 -i 0.3 -w 1 "${peerIP}" 2>&1 | tail -n 1 | cut -d/ -f5 | cut -d. -f1)
      echo "---------------------------------------"
    else # Incoming connection, ping failed, set as unreachable
      #peerRTT=99999
      echo "Incoming connection, ping failed, Unreachable"
      echo "DROP IP"
      #sudo iptables -A INPUT -s "${peerIP}" -p icmp -j DROP
      #sudo iptables -A INPUT -s "${peerIP}" -p tcp -j DROP
      sudo iptables -A INPUT -s "${peerIP}" -j DROP
      echo "---------------------------------------"
    fi
    lastpeerIP=${peerIP}
done
# Save Unique rule iptables and Restore
sudo iptables-save | awk '/^COMMIT$/ { delete x; }; !x[$0]++' > /tmp/iptables.conf
sudo iptables -F
sudo iptables-restore < /tmp/iptables.conf
sudo iptables -L
