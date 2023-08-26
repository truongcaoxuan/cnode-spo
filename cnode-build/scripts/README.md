# Cardano SPO Scripts

## check-leadership-schedule

This scripts using for Cardano SPO to query leadership schedule

### Step1: Copy files and scripts

```leadeship
cp pool-list.json /opt/cardano/cnode/files/
cp check-leadership.sh /opt/cardano/cnode/scripts/
```

### Step2: Modify your pool-list

```leadeship
nano /opt/cardano/cnode/files/pool-list.json
```

### Step3: Run check leadership script

```leadeship
cd /opt/cardano/cnode/scripts
chmod +x check-leadership.sh
./check-leadership.sh
```

**The file data leadership schedule store in /tmp/data-leadership.txt*

## check-ping-tip.sh

It reports the the server is in sync to Healthchecks.io If no signal goes out Healthchecks.io is triggering an alert.
This script is to be run by a cron Job.

How to install:

* Create Healthcheck.io Account
* Create a new Check with a 5 minutes period and 1 minute grace time
* Store script on your server
* Make it executable

```chmod
chmod +x check-ping-tip.sh
```

Create Crontab Job using command

```cronjob
crontab -u user -e
```

Copy config below and paste into crontab

```cronconfig
* * * * * /opt/cardano/cnode/custom/check-ping-tip.sh
```

## setup_note_exporter.sh

This script use for instal node-exporter for your node

```setup
cp setup_note_exporter.sh /opt/cardano/cnode/scripts/
cd /opt/cardano/cnode/scripts/
chmod +x setup_note_exporter.sh
./setup_note_exporter.sh
```
