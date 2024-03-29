# Move Cnode from GCP's User 1 to GCP's User 2

## --STEP1: Tranfer IMAGES from User1 to User2

## --STEP2: Create VM on User2

SSH to VM and change User

```bash
sudo usermod -aG sudo user2
sudo adduser user2 cnode
sudo rsync -va /home/user1/ /home/user2
sudo chown -R user2:sudo /opt/cardano
sudo chown -R user2:sudo /home/user2/
sudo deluser user1
sudo deluser --remove-home user1
echo export PATH=~/.cabal/bin:$PATH >> ~/.bashrc
source ~/.bashrc
sudo reboot
```

## --STEP3: Create Firewall rule

host-port rule

- name: host-port
- network-tag: host
- ip-range: 0.0.0.0/0
- tcp-port: 5000,9100,9093,9087,80,443

relay-peer-port rule

- name: relay-peer-port
- network-tag: noderelay
- ip-range: 0.0.0.0/0
- tcp-port: 6000

core-peer-port rule

- name: core-peer-port
- network-tag: core
- ip-range: [RELAY-IP-ADDR-INTERNAL]
- tcp-port: 3008

monitoring-port rule

- name: monitoring-port
- network-tag: core / relay / host
- ip-range: [HOST-IP-ADDR-EXTERNAL],[127.0.0.1]
- tcp-port: 9091,12798

## --STEP4: Make Static External IP ADDR for VM

## --STEP5: Update Crontab
