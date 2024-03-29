# Cardano SPO Bash Shell Scripts

## Cardano Scripts to to create a stake pool

Assuming you have an existing address to pay your desposit cost and pledge fee with
TTL is the time in slots to wait until considering this transaction failed if not processed

In this example we will use

* Relay Node IP: 1.1.1.1
* Relay Node Port: 3000
* Core Node IP: 2.2.2.2
* Core Node Port: 3001

Steps >>

## User Steps

./make-cardano-sudo-user.sh

## Basic Harden Steps

./harden-node.sh

## Step 1: Harden your core server

[See also: Harden Ubuntu](https://www.lifewire.com/harden-ubuntu-server-security-4178243)
[See also: Secure Ubuntu](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3)

* SSL only via keys, not password
* Change SSL default port from 22
* Allow SSL only from your relay node(s)
* Close all unneeded ports except SSL and the core node port 3001

## Step 2: Harden your relay server

[See also: Harden Ubuntu](https://www.lifewire.com/harden-ubuntu-server-security-4178243)
[See also: Secure Ubuntu](https://gist.github.com/lokhman/cc716d2e2d373dd696b2d9264c0287a3)

* SSL only via keys, not password
* Change SSL default port from 22
* Allow SSL only from where absolutely needed
* Close all unneeded ports except SSL and the relay node port 3000

## Step 3: Build the cardano-cli and cardano

`./build-node-code.sh CABAL_VERSION GHC_VERSION CARDANO_NODE_VERSION`

Latest current versions are 3.6.2.0 for CABAL_VERSION, 8.10.7 for GHC_VERSION and 1.35.3 for CARDANO_NODE_VERSION

## Step 4

`./set-net.sh mainnet|testnet [TESTNET_MAGIC_ID]`

Set the net you want to run on (testnet or mainnet)
Will also automatically download the respective configuration files, i.e. it will automatically run `./get-config.sh conf testnet|mainnet`

## Step 4.5

`./create-node-runner-binary.sh full|relay|core NETWORK_INTERFACE_NODE_IP NETWORK_INTERFACE_NODE_PORT`

Create the executable that will run your cardano node. Determine which node type (you will start with a full node first, so you can get the blockchain and perform the transactions required to register your stakepool, before you can create a relay or core node)
Make sure to use the IP and port that your network interface has, which could be different (for example in AWS) from your public IP4 address.

## Step 4.6

`./create-node-runner-service.sh full|relay|core`

Create a systemd script for your node and install it. This will ensure your node will auto-restart if it crashes or if the server restarts. You can now run your node with

`sudo systemctl start cardano-node`

and get its status with

`sudo systemctl status cardano-node`

current log files with

`journalctl --unit=cardano-node --follow`

## Step 5: Make a stake address and stake payment address (only on Airgapped Offline Machine!)

`./offline-make-stake-and-payment-addresses.sh stake stake-payment`

## Step 5.5: Set up payment address and keys

* Create a payfrom.addr file containing the address you will pay from (WARNING: All funds in that address will be transferred and it can only have one transaction in it!)
`./make-keys-and-address.sh payfrom`

Copy addr/payfrom.addr to your online node

## Step 5.7: Create stake registration certificate (only on Airgapped Offline Machine!)

`./offline-create-stake-registration-cert.sh stake`

## Step 6: Register the stake address with the cardano net (online machine)

`./register-stake-address.sh TTL payfrom stake-payment stake`

Sign the transaction on the offline machine
`./offline-register-stake-address-sign.sh`

Copy the transaction back to your core node and submit it
`./submit-transaction.sh`

## Step 7: Verify stake funding is present

`./query.sh stake-payment`

## Generate Topology files for your nodes

`./create-pool-topology-files.sh`

## Replace topology files on both core and relay nodes

## Restart Relay Node(s)

`sudo systemctl restart cardano-node`

## Restart Core Node

`sudo systemctl restart cardano-node`

## Create Metadata file (online machine)

`./create-pool-metadata-file.sh POOLNAME POOLDESCRIPTION POOLTICKER POOLHOMEPAGE`

## Upload Metadata file to a URL with less than 65 characters

## Copy pool relay info

Copy the topology and metadata folders to your airgapped offline machine

## Create Stake Pool Keys (only on Airgapped Offline Machine!)

`./offline-create-pool-keys.sh`

## Generate Stake Pool Registration Certificate (only on Airgapped Offline Machine!)

`./offline-generate-stake-pool-registration-certificate.sh METADATAURL`

## Generate the stake pool registration transaction (on your online machine)

`./build-stake-pool-registration-transaction.sh TTL`

## Sign the stake pool registration transaction (only on Airgapped Offline Machine!)

`./offline-build-stake-pool-registration-transaction.sh`

## Transfer your Pledge and Deposit

Transfer it using your wallet of choice to the address in addr/payfrom.addr

## Submit Transaction for Stake Pool Registration and Deposit Payment

`./submit-transaction.sh`

---------------------------------------------------------------

## Create rewards transfer transaction by running this command

`./transfer-rewards-create-transaction.sh TTL TARGETADDRESS`

## Copy txtmp/tx.raw to your offline machine

## Sign the rewards transfer transaction by running this command

`./transfer-rewards-sign-transaction.sh TARGETADDRESS`

## Copy txtmp/tx.signed back into the txtmp folder of your online machine

## Submit the transaction

`./submit-transaction.sh`

---------------------------------------------------------------

## Rotate KES keys

First, on the live block producer node run
`./prepare-new-kes-key-files.sh`

Then copy the KES files over to your offline machine and as instructed, run
`./offline-regenerate-nodecert-for-kes-key KES_PERIOD`

Verify counter # is correct as described here:
<https://ecp.gitbook.io/how-to-guides-for-coincashew-method-cardano-spos/maintenance-and-daily-operations/maintenance-and-daily-operations/adjust-node.counter-for-kes>

Copy the new node-op.cert file from the certs subfolder back onto your core node and run
`sudo systemctl restart cardano-node` or (if security updates are required) `sudo reboot`

Use the opportunity to reboot the relay(s) as well

---------------------------------------------------------------

## Update Pledge or metadata etc for your pool without paying the deposit again

On offline machine, make certs/pool-*.cert writable again
Run
`./offline-generate-stake-pool-registration-certificate METDATAURL`

Copy the two certs/pool-*.cert files to your core node
Run
`./build-update-stake-pool-registration-transaction.sh TTL`

Copy txtmp/tx.raw to your offline machine
Run
`./offline-build-stake-pool-registration-transaction.sh`

Copy txtmp/tx.signed back to your core nore
Run
`./submit-transaction.sh`

---------------------------------------------------------------

## Update node version/binary

Build the cardano-cli and cardano with the new version
`./update-node-code.sh GHC_VERSION CARDANO_NODE_VERSION`

Stop the service
`sudo systemctl stop cardano-node`

Update the binaries and back up the old ones
`./update-node-binary.sh GHC_VERSION CARDANO_NODE_VERSION`

Start the service again
`sudo systemctl start cardano-node`

---------------------------------------------------------------

## check-leadership-schedule

This scripts using for Cardano SPO to query leadership schedule

### Copy files and scripts

```leadeship
cp check-leadership-pool-list.json /opt/cardano/cnode/files/
cp check-leadership.sh /opt/cardano/cnode/scripts/
```

### Modify your pool-list

```leadeship
nano /opt/cardano/cnode/files/check-leadership-pool-list.json
```

### Run check leadership script

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

---------------------------------------------------------------

## telegram-send-leaderlog.sh

**Package needed**: **jq** (sudo apt install jq)

A simple bash script to parse leaderlog.json (created by **cncli** - <https://github.com/AndrewWestberg/cncli>) and send a notification via Telegram bot

You need to customize and replace:

* **LEADERLOG.JSON**: replace it with the path to your leaderlog.json, you can use curl or cat it and pipe to jq
* **APIKEY**: API key of your telegram bot
* **CHAT_ID**: Chat ID of your telegram public/private group

You can put it in your crontab and schedule it

## ada-airdrop.sh

**Package needed**: **default-mysql-client** (sudo apt install default-mysql-client)

Bash script used to update stake quantity and drop participation based on staked amount. MySQL/MariaDB db used.
URL: <https://ada-airdrop.hwlegnano.it/>

You need to customize and replace:

* **ID**: replace it with your Blockfrost project ID
* **USER**: replace it with your DB user
* **SCHEMA**: replace it with your DB schema (DB)
* **HOST**: replace it with your DB host provider
* **TABLE**: replace it with your DB schema table

You can put it in your crontab and schedule it

## ftp-leaderlog-put.sh

**Package needed**: **ftp** (sudo apt install ftp)

Bash script used to upload calculated leaderlog (by cncli-leaderlog-snapshot.sh) to a remote hosting provider.
URL: <https://www.hwlegnano.it/cardano/>

You need to fill in these variables:

* **HOST**: fill in your HOSTNAME
* **USER**: fill in your USER
* **PASSWORD**: fill in your PASSWORD 

You can put it in your crontab and schedule it after cncli-leaderlog-snapshot.sh

## cncli-leaderlog-snapshot.sh

**Package needed**: **cncli** (<https://github.com/AndrewWestberg/cncli>)
URL: <https://www.hwlegnano.it/cardano/>

This script calls cncli to calculate leaderlog.
This script must:

* be run 18 hours or earlier prior to epoch end
* have cncli.db available --- /usr/local/bin/cncli sync --host 127.0.0.1 --port 6000 --db /home/USER/cardano-node/scripts/cncli.db --- strongly recommended to run this as systemd service

You need to customize and replace:

* **USER**: replace with your $home user
* **POOL_ID**: replace with your pool id (you can find it in adapools.org)

You can put it in your crontab and schedule it after cncli-leaderlog-snapshot.sh

## leaderlog_minted.php

Simple php code to fetch leaderlog.json and print slots/blocks minted, missed and coming so far.
URL: <https://www.hwlegnano.it/cardano/>

You need to fill in these variables:

\_URL: fill in your URL to fetch leaderlog.json from
\_POOL: fill in your pool ID, you can easily find it in adapools.org
1_TOKEN: if you use Basic Auth to protect leaderlog.json, fill in your auth token
2_TOKEN: register on blockfrost.io and fill in your project id

### Contacts

* Telegram: <https://t.me/ItalyADAPool>
* Website: <https://www.hwlegnano.it/contatta>

---------------------------------------------------------------

## How to create a cardano-db-sync out of nowhere

Install Ubuntu 22.04
Deploy these scripts into a script folder and make them executable
Create a cardano user and make him sudo via
`./make-cardano-sudo-user.sh`

Log in as the cardano user

Install docker-compose
`sudo apt install apt-transport-https ca-certificates curl software-properties-common`
`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`
`sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"`
`sudo apt-get install docker-ce docker-compose`
`sudo systemctl enable docker`
`sudo systemctl start docker`
`sudo usermod -aG docker cardano`
`sudo reboot`

Log in as the cardano user again
Execute
`git clone https://github.com/input-output-hk/cardano-db-sync.git`
`cd cardano-db-sync`
`git checkout tags/13.0.5`

Edit the docker-compose.yml file and comment out the db-sync and postgres services and corresponding volumes and run `docker-compose up -d`
Run `docker-compose stop` after 30 seconds
Copy the backed up db directory of a fully synched node into the cardano-node-db volume location and set file permissions to match the existing file permissions. Make sure to delete the existing ledger files.
Run `docker-compose start` and wait until the the cardano-node is fully synched
Uncomment the previously commented out services in the docker-compose.yml file

Run this with the correct snapshot from <https://update-cardano-mainnet.iohk.io/cardano-db-sync/index.html> matching your cardano-db-sync version
`RESTORE_SNAPSHOT=https://update-cardano-mainnet.iohk.io/cardano-db-sync/13/db-sync-snapshot-schema-13-block-7770734-x86_64.tgz NETWORK=mainnet docker-compose up -d`

Then to see the progress, run
`docker-compose logs -f`
