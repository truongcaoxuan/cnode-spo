## Install docker
```
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y docker.io
sudo groupadd docker
sudo usermod -aG docker `whoami`
```

## Install docker-compose
```
sudo apt install -y docker-compose
```

## Git clone
```
mkdir /opt/cardano/
cd /opt/cardano/
git clone https://github.com/truongcaoxuan/cnode-spo.git
cd cnode-spo/monitoring/
git clone https://github.com/truongcaoxuan/prometheus_bot.git
```

## Run docker compose up monitoring
Use .env config
```
cd /opt/cardano/cnode-docker-compose
docker-compose config
docker-compose up -d
```
Use .env.core config
```
docker-compose --env-file .env.core config
docker-compose --env-file .env.core up -d
```
Use .env.relay config
```
docker-compose --env-file .env.relay config
docker-compose --env-file .env.relay up -d
```

### Other docker compose command
```
docker-compose down
docker rm -f $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
```
