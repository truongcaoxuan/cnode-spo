This scripts using for Cardano SPO to query leadership schedule

## Step1: Git it
```
git clone https://github.com/truongcaoxuan/cnode-leadership-schedule.git
```

## Step2: Copy files and scripts
```
cd cnode-leadership-schedule
cp pool-list.json /opt/cardano/cnode/files/
cp check-leadership.sh /opt/cardano/cnode/scripts/
```

## Step3: Modify your pool-list
```
nano /opt/cardano/cnode/files/pool-list.json
```
*With JSON Format example in pool-list.json files*


## Step4: Run check leadership script
```
cd /opt/cardano/cnode/scripts
chmod +x check-leadership.sh
./check-leadership.sh
```
*The file data leadership schedule store in /tmp/data-leadership.txt*
