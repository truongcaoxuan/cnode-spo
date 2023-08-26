# Run Cardano Node using Docker compose

## Install docker

```bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y docker.io
sudo groupadd docker
sudo usermod -aG docker `whoami`
```

## Install docker-compose

```bash
sudo apt install -y docker-compose
```

## Run docker compose up monitoring

Use .env config

```bash
cd /opt/cardano/cnode-docker-compose
docker-compose config
docker-compose up -d
```

Use .env.core config

```bash
docker-compose --env-file .env.core config
docker-compose --env-file .env.core up -d
```

Use .env.relay config

```bash
docker-compose --env-file .env.relay config
docker-compose --env-file .env.relay up -d
```

## Other docker compose command

```bash
docker-compose down
docker rm -f $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
```

## Link ref

- <https://github.com/PagerTree/prometheus-grafana-alertmanager-example>
