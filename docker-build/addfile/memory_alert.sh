#!/bin/bash
ramusage=$(free | awk '/Mem/{printf("RAM Usage: %.2f\n"), $3/$2*100}'| awk '{print $3}')
num_ramusage=$(numfmt --from auto "$ramusage" 2>&-)
#Alert action :: Reboot
if [[ $num_ramusage > 85 ]]; then
  #sudo /usr/local/bin/telegram-send "[Relay1] CronJobs @reboot :: High RAM Usage :: ~ $ramusage% {user only}"
  #sleep 5s
  #sudo /usr/sbin/reboot
  sudo systemctl restart cnode.service
  #echo $ramusage
fi
