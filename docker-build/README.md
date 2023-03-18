#PREREQ :: INSTALL DOCKER

Option1: manual install docker step by step in **docker-install-guide-manual.txt**

Option 2: automatic installl docker by run **docker-install.sh**

NEXT STEP >>

**CLONE CNODE DOCKER BUILD**

#* update git to automatically set line ending to LF
```
git config --global core.eol lf
git config --global core.autocrlf input
git clone https://github.com/truongcaoxuan/cnode-docker.git
```
#============================================================

# DOCKER BUILD CNODE : START!

#============================================================

**---- STEP1 ----**
```
docker pull cardanocommunity/cardano-node:stage1
```
**---- STEP2 ----**
```
docker build --force-rm -t vnpip/cnode:stage2 -f dockerfile_stage2 .
```

#docker tag IMAGE vnpip/cnode:stage2

**---- STEP3 ----**

**Build IMAGE (default have no db)**
```
docker build --force-rm -t vnpip/cnode:stage3 -f dockerfile_stage3 .
docker build --force-rm --build-arg=NONEROOTUSER=vnpip -t vnpip/cnode:stage3 -f dockerfile_stage3 .
```
**Commit IMAGE from Container with db sync**
```
docker commit CONTAINER  truongcx/cnode-commit
```
#============================================================

DOCKER BUILD CNODE : DONE! 

#============================================================

**--Tag IMAGE**
```
docker tag IMAGE vnpip/cnode:stage3
```
**RUNNING TEST CONTAINER**
```
docker network create cardano-mainnet
docker run -ti --privileged --rm --network=cardano-mainnet -p 6000:6000 -p 12798:12798 --name relay1 vnpip/cnode:stage3
docker run -ti --privileged --rm --network=cardano-mainnet -p 6000:6000 -p 12798:12798 --name relay1 vnpip/cnode-commit
```
**RUNNING CONTAINER**
```
docker network create cardano-mainnet
docker run -dti --privileged --network=cardano-mainnet --restart always -p 6000:6000 -p 12798:12798 --name relay1 vnpip/cnode:stage3
docker run -dti --privileged --network=cardano-mainnet --restart always -p 6000:6000 -p 12798:12798 --name relay1 vnpip/cnode-commit
```
# --Docker Images
```
docker images
docker rmi IMAGES
```
# --Docker Container
```
docker ps
docker ps -a
docker rm CONTAINER
docker exec -ti CONTAINER /bin/bash
docker attach CONTAINER
docker update --restart always CONTAINER
docker inspect CONTAINER
```
**--Exit container**

Ctrl-P /Ctrl-Q

**--Start / Stop cnode**
```
nodestart
nodestop
```
**--crontab setting**
```
crontab -e
```
**--run gLiveView**

gLiveView

# --- PUSH IMAGE TO DOCKER HUB ---
```
docker login -u USER -p PASSWORD
```
**--Tag Build Images to Docker Hub Tag**
```
docker tag cardanocommunity/cardano-node:stage1 vnpip/cnode:stage1
```
**--Push Images to Docker Hub**
```
docker push vnpip/cnode:stage1
docker push vnpip/cnode:stage2
docker push vnpip/cnode:stage3
docker push vnpip/cnode-commit
```
**VM/ Host crontab**
```
#== WEKKLY ===
#--: At 00:10 on Monday
10 0 * * 1    sudo apt-get update -y
#--: At 00:20 on Monday
20 0 * * 1   sudo apt-get upgrade -y
#--: At 00:30 on Monday
30 0 * * 1   sudo apt autoremove
#--: At 00:40 on Monday
40 0 * * 1   sudo apt-get clean
#---------------------------------------------------------------
11 2 * * * docker exec relay1 /home/vnpip/.scripts/clearlogs.sh
#---------------------------------------------------------------
5 * * * * docker exec relay1 /opt/cardano/cnode/scripts/topologyUpdater.sh 
#---------------------------------------------------------------
17 2 * * * sudo sh -c "truncate -s 0 /var/lib/docker/containers/'*'/'*'-json.log"
#---------------------------------------------------------------
*/20 * * * * docker exec relay1 /home/vnpip/.scripts/peerIN_check.sh 
10 */24 * * * docker exec relay1 sudo /usr/sbin/iptables -F
```

# --Source Docker Hub

https://hub.docker.com/r/vnpip/cnode

https://hub.docker.com/r/cardanocommunity/cardano-node

https://hub.docker.com/r/inputoutput/cardano-node

# --Source Dockerfile

https://github.com/cardano-community/guild-operators/tree/fa29ea533c33b1b561cd3faeb60fa03255f7b43b/files/docker/node

https://gitlab.com/viper-staking/docker-containers/-/tree/master/cardano-node
