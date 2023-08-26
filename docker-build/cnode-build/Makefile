.ONESHELL:

CARDANO_NODE_DOCKERFILE=$(PWD)/Dockerfile
CARDANO_NODE_SERVICEFILE=$(PWD)/services/cardano-node.service
PROMETHEUS_SERVICEFILE=$(PWD)/services/prometheus.service
PROMETHEUS_CONFIG_FILE=$(PWD)/prometheus.yml
GHC_VERSION=8.10.2
CABAL_VERSION=3.2.0.0
LIBSODIUM_VERSION=66f017f1
CARDANO_NODE_VERSION=1.25.1
PROMETHEUS_VERSION=2.25.0

INSTALL_DIR=/usr/local/
OS_ARCH=$(shell uname -m)

# NETWORK=mainnet
# NETWORK_PARAMETER=

NETWORK=testnet
NETWORK_PARAMETER=-magic 1097911063

PUBLIC_IP=159.203.58.57
POOL_DIR=$(PWD)/pool
WALLET_DIR=$(POOL_DIR)/wallet
RELAY_NODE_DIR=$(POOL_DIR)/relay
STAKING_NODE_DIR=$(POOL_DIR)/node
NODE_KEY_DIR=$(STAKING_NODE_DIR)/keys
LOCAL_KEY_DIR=$(PWD)/keys
STAKING_NODE_PORT=3002
RELAY_NODE_PORT=3000

export CARDANO_NODE_SOCKET_PATH=$(RELAY_NODE_DIR)/socket
export LD_LIBRARY_PATH=/usr/local/lib
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# help extracts the help texts for the comments following ': ##'
.PHONY: help
help: ## Print this help message
	@awk -F':.*## ' ' \
		/^[[:alpha:]_-]+:.*## / { \
			printf "\033[36m%s\033[0m\t%s\n", $$1, $$2 \
		} \
	' $(MAKEFILE_LIST) | column -s$$'\t' -t

.PHONY: update
update: ## update ubuntu and setup required dependencies
	apt-get update
	apt-get upgrade -y
	apt-get install -y --no-install-recommends netbase jq libnuma-dev docker.io nginx
	sudo systemctl start docker
	sudo systemctl start nginx
	sudo systemctl enable nginx

.PHONY: build-cardano
build-cardano: ## builds cardano node binaries in a docker
	nohup docker build \
		--tag cardano-node:${CARDANO_NODE_VERSION}-${OS_ARCH} \
		--build-arg OS_ARCH="${OS_ARCH}" \
		--build-arg GHC_VERSION=${GHC_VERSION} \
		--build-arg CABAL_VERSION=${CABAL_VERSION} \
		--build-arg LIBSODIUM_VERSION=${LIBSODIUM_VERSION} \
		--build-arg CARDANO_NODE_VERSION=${CARDANO_NODE_VERSION} \
		-f $(CARDANO_NODE_DOCKERFILE) . > binary.out 2>&1 &
	tail -f binary.out

.PHONY: get-binary
get-binary: ## move binaries built in docker to the local machine
	mkdir -p ${INSTALL_DIR}
	docker run \
		--volume ${INSTALL_DIR}:/dist \
		cardano-node:${CARDANO_NODE_VERSION}-${OS_ARCH} \
		"cp /usr/local/bin/cardano* /dist; \
			mkdir -p /dist/lib/ && cp -r /usr/local/lib/lib* /dist/lib; \
			mkdir -p /dist/lib/pkgconfig && cp -r /usr/local/lib/pkgconfig/lib* /dist/lib/pkgconfig"

.PHONY: get-prometheus
get-prometheus: ## install prometheus
	wget -nc -q https://github.com/prometheus/prometheus/releases/download/v$(PROMETHEUS_VERSION)/prometheus-$(PROMETHEUS_VERSION).linux-amd64.tar.gz
	tar xfz prometheus-$(PROMETHEUS_VERSION).linux-amd64.tar.gz
	cd prometheus-$(PROMETHEUS_VERSION).linux-amd64
	mv ./prometheus /usr/local/bin/
	cd .. && rm -rf prometheus*

.PHONY: setup-prometheus
setup-prometheus: ## setup prometheus service
	@sed \
		-e 's:PROMETHEUS_CONFIG_FILE:$(PROMETHEUS_CONFIG_FILE):g' \
		$(PROMETHEUS_SERVICEFILE) > /etc/systemd/system/prometheus.service
	sudo systemctl enable prometheus
	sudo systemctl start prometheus
	sudo systemctl status prometheus

define get-config-files
	@wget -nc -qP $(1) https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-config.json
	wget -nc -qP $(1) https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-byron-genesis.json
	wget -nc -qP $(1) https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-shelley-genesis.json
	wget -nc -qP $(1) https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-topology.json
	wget -nc -qP $(1) https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json
	wget -nc -qP $(1) https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-byron-genesis.json
	wget -nc -qP $(1) https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-shelley-genesis.json
	wget -nc -qP $(1) https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-topology.json
	sed -i 's/\(TraceBlockFetchDecisions": \).*$$/\1true,/g' $(1)/mainnet-config.json
	sed -i 's/\(TraceBlockFetchDecisions": \).*$$/\1true,/g' $(1)/testnet-config.json
endef

.PHONY: get-relay-node-config-files
get-relay-node-config-files: ## download relay node config files
	@$(call get-config-files,$(RELAY_NODE_DIR))
	[[ grep -c $(PUBLIC_IP) $(RELAY_NODE_DIR)/testnet-topology.json -eq 0 ]] && sed -i \
		's/\("valency": 2\)/\1 \
    },{ \
      "addr": "$(PUBLIC_IP)",\
      "port":$(STAKING_NODE_PORT),\
      "valency":1/g' \
		$(RELAY_NODE_DIR)/testnet-topology.json

.PHONY: get-staking-node-config-files
get-staking-node-config-files: ## download staking node config files
	@$(call get-config-files,$(STAKING_NODE_DIR))
	sed -i \
		-e 's/"addr": .*$$/"addr": "$(PUBLIC_IP)",/g' \
		-e 's/"port": .*$$/"port": $(RELAY_NODE_PORT),/g' \
		-e 's/"valency": .*$$/"valency": 1/g' \
		$(STAKING_NODE_DIR)/testnet-topology.json
	sed -i \
		-e 's/12798/12799/g' \
		-e 's/12788/12789/g' \
		$(STAKING_NODE_DIR)/testnet-config.json
	sed -i \
		-e 's/12798/12799/g' \
		-e 's/12788/12789/g' \
		$(STAKING_NODE_DIR)/mainnet-config.json

.PHONY: setup-relay-node-service
setup-relay-node-service: ## setup relay node service and enable it to start on restart
	@sed \
		-e 's:NAME:Cardano Relay Node Service:g' \
		-e 's:NODE_DIR:$(RELAY_NODE_DIR):g' \
		-e 's:NODE_PORT:$(RELAY_NODE_PORT):g' \
		-e 's:PUBLIC_IP:$(PUBLIC_IP):g' \
		-e 's:NETWORK:$(NETWORK):g' \
		-e 's:ADDITIONAL_PARAMS::g' \
		$(CARDANO_NODE_SERVICEFILE) > /etc/systemd/system/cardano-relay-node.service
	sudo systemctl daemon-reload
	sudo systemctl enable cardano-relay-node

.PHONY: start-relay-node
start-relay-node: ## start relay node service
	@sudo systemctl start cardano-relay-node
	sudo systemctl status cardano-relay-node

.PHONY: stop-relay-node
stop-relay-node: ## stop relay node service
	@sudo systemctl stop cardano-relay-node
	sudo systemctl status cardano-relay-node

.PHONY: check-relay-tip
check-relay-tip: ## check relay node tip
	@cardano-cli query tip --$(NETWORK)$(NETWORK_PARAMETER) | jq
	cardano-cli query protocol-parameters --mary-era \
		--$(NETWORK)$(NETWORK_PARAMETER) \
		--out-file $(POOL_DIR)/protocol.json

.PHONY: setup-staking-node-service
setup-staking-node-service: ## setup staking node service and enable it to start on restart
	@sed \
		-e 's:NAME:Cardano Block Producing Node Service:g' \
		-e 's:NODE_DIR:$(STAKING_NODE_DIR):g' \
		-e 's:NODE_PORT:$(STAKING_NODE_PORT):g' \
		-e 's:PUBLIC_IP:$(PUBLIC_IP):g' \
		-e 's:NETWORK:$(NETWORK):g' \
		-e 's:ADDITIONAL_PARAMS:--shelley-kes-key $(NODE_KEY_DIR)/kes.skey --shelley-vrf-key $(NODE_KEY_DIR)/vrf.skey --shelley-operational-certificate $(NODE_KEY_DIR)/node.cert:g' \
		$(CARDANO_NODE_SERVICEFILE) > /etc/systemd/system/cardano-staking-node.service
	sudo systemctl daemon-reload
	sudo systemctl enable cardano-staking-node

.PHONY: start-staking-node
start-staking-node: ## start staking node service
	@sudo systemctl start cardano-staking-node
	sudo systemctl status cardano-staking-node

.PHONY: stop-staking-node
stop-staking-node: ## stop staking node service
	@sudo systemctl stop cardano-staking-node
	sudo systemctl status cardano-staking-node

.PHONY: check-node-tip
check-node-tip: ## check staking node tip
	@CARDANO_NODE_SOCKET_PATH=$(STAKING_NODE_DIR)/socket \
	cardano-cli query tip --$(NETWORK)$(NETWORK_PARAMETER) | jq

.PHONY: get-balance
get-payment-balance: ## get balance for payment address from relay node
	@cardano-cli query utxo --mary-era \
		--address $(shell cat $(WALLET_DIR)/payment.addr) \
		--$(NETWORK)$(NETWORK_PARAMETER)

.PHONY: submit-tx
submit-tx: ## submits the signed transaction to the network
	cardano-cli transaction submit \
		--tx-file tx.signed \
		--$(NETWORK)$(NETWORK_PARAMETER)

local-pool-deregister:
	cardano-cli stake-pool deregistration-certificate \
		--cold-verification-key-file cold.vkey \
		--epoch 118 \
		--out-file pool.deregistration.cert

local-generate-keys:
	@mkdir -p $(LOCAL_KEY_DIR)
	cardano-cli address key-gen \
		--verification-key-file $(LOCAL_KEY_DIR)/payment.vkey \
		--signing-key-file $(LOCAL_KEY_DIR)/payment.skey
	cardano-cli stake-address key-gen \
		--verification-key-file $(LOCAL_KEY_DIR)/stake.vkey \
		--signing-key-file $(LOCAL_KEY_DIR)/stake.skey
	cardano-cli address build \
		--payment-verification-key-file $(LOCAL_KEY_DIR)/payment.vkey \
		--stake-verification-key-file $(LOCAL_KEY_DIR)/stake.vkey \
		--out-file $(LOCAL_KEY_DIR)/payment.addr \
		--$(NETWORK)$(NETWORK_PARAMETER)
	cardano-cli stake-address build \
		--stake-verification-key-file $(LOCAL_KEY_DIR)/stake.vkey \
		--out-file $(LOCAL_KEY_DIR)/stake.addr \
		--$(NETWORK)$(NETWORK_PARAMETER)
	cardano-cli stake-address registration-certificate \
		--stake-verification-key-file $(LOCAL_KEY_DIR)/stake.vkey \
		--out-file $(LOCAL_KEY_DIR)/stake.cert
	cardano-cli node key-gen \
		--cold-verification-key-file $(LOCAL_KEY_DIR)/cold.vkey \
		--cold-signing-key-file $(LOCAL_KEY_DIR)/cold.skey \
		--operational-certificate-issue-counter-file $(LOCAL_KEY_DIR)/cold.counter
	cardano-cli node key-gen-VRF \
		--verification-key-file $(LOCAL_KEY_DIR)/vrf.vkey \
		--signing-key-file $(LOCAL_KEY_DIR)/vrf.skey
	cardano-cli node key-gen-KES \
		--verification-key-file $(LOCAL_KEY_DIR)/kes.vkey \
		--signing-key-file $(LOCAL_KEY_DIR)/kes.skey
	cardano-cli node issue-op-cert \
		--kes-verification-key-file $(LOCAL_KEY_DIR)/kes.vkey \
		--cold-signing-key-file $(LOCAL_KEY_DIR)/cold.skey \
		--operational-certificate-issue-counter $(LOCAL_KEY_DIR)/cold.counter \
		--kes-period 156 \
		--out-file $(LOCAL_KEY_DIR)/node.cert

local-get-metadata-hash:
	cardano-cli stake-pool metadata-hash --pool-metadata-file $(file)

local-generate-stake-pool-certificate:
	cardano-cli stake-pool registration-certificate \
		--cold-verification-key-file $(LOCAL_KEY_DIR)/cold.vkey \
		--vrf-verification-key-file $(LOCAL_KEY_DIR)/vrf.vkey \
		--pool-pledge 100000000 \
		--pool-cost 340000000 \
		--pool-margin 0.01 \
		--pool-reward-account-verification-key-file $(LOCAL_KEY_DIR)/stake.vkey \
		--pool-owner-stake-verification-key-file $(LOCAL_KEY_DIR)/stake.vkey \
		--$(NETWORK)$(NETWORK_PARAMETER) \
		--pool-relay-ipv4 $(PUBLIC_IP) \
		--pool-relay-port $(RELAY_NODE_PORT) \
		--metadata-url $(url) \
		--metadata-hash $(metadata_hash) \
		--out-file $(LOCAL_KEY_DIR)/pool-registration.cert
	cardano-cli stake-address delegation-certificate \
		--stake-verification-key-file $(LOCAL_KEY_DIR)/stake.vkey \
		--cold-verification-key-file $(LOCAL_KEY_DIR)/cold.vkey \
		--out-file $(LOCAL_KEY_DIR)/delegation.cert

local-get-stake-pool-id:
	cardano-cli stake-pool id --cold-verification-key-file $(LOCAL_KEY_DIR)/cold.vkey

local-move-tx-to-server:
	sftp do-cardano-spo << EOF
	cd /root/cardano-spo
	put tx.signed
	quit
	EOF

local-move-keys-to-server:
	cd $(LOCAL_KEY_DIR) && sftp do-cardano-spo << EOF
	cd /root/cardano-spo/pool/wallet
	rm payment.skey
	put payment.skey
	rm payment.vkey
	put payment.vkey
	rm payment.addr
	put payment.addr
	rm stake.skey
	put stake.skey
	rm stake.vkey
	put stake.vkey
	rm stake.addr
	put stake.addr
	rm stake.cert
	put stake.cert
	cd /root/cardano-spo/pool/node/keys
	rm vrf.skey
	put vrf.skey
	rm vrf.vkey
	put vrf.vkey
	rm kes.skey
	put kes.skey
	rm kes.vkey
	put kes.vkey
	rm node.cert
	put node.cert
	rm pool-registration.cert
	put pool-registration.cert
	rm delegation.cert
	put delegation.cert
	quit
	EOF

define tx/fee
	$(eval txIns := $(foreach txIn,$(1),--tx-in $(txIn) ))
	$(eval certs := $(foreach cert,$(2),--certificate-file $(cert) ))
	cardano-cli transaction build-raw \
		--mary-era \
		$(txIns) \
		--tx-out $(shell cat $(WALLET_DIR)/payment.addr)+0 \
		--invalid-hereafter 0 \
		--fee 0 \
		--out-file tx.raw \
		$(certs)
	cardano-cli transaction calculate-min-fee \
		--tx-body-file tx.raw \
		--tx-in-count $(words $(1)) \
		--tx-out-count 1 \
		--witness-count 1 \
		--byron-witness-count 0 \
		--$(NETWORK)$(NETWORK_PARAMETER) \
		--protocol-params-file $(POOL_DIR)/protocol.json
endef

define tx/sign
	$(eval txIns := $(foreach txIn,$(1),--tx-in $(txIn) ))
	$(eval certs := $(foreach cert,$(2),--certificate-file $(cert) ))
	$(eval keys := $(foreach key,$(3),--signing-key-file $(key) ))
	cardano-cli transaction build-raw \
		$(txIns) \
		--tx-out $(shell cat $(LOCAL_KEY_DIR)/payment.addr)+$(strip $(4)) \
		--invalid-hereafter $(5) \
		--fee $(6) \
		--out-file tx.raw \
		$(certs)
	cardano-cli transaction sign \
		--tx-body-file tx.raw \
		$(keys) \
		--$(NETWORK)$(NETWORK_PARAMETER) \
		--out-file tx.signed
endef

.PHONY: stake-tx-fee
stake-tx-fee: ## gets minimum fee for the given stake tx
	@$(call tx/fee,$(txIn),$(WALLET_DIR)/stake.cert)

local-sign-stake-tx:
	@$(call tx/sign,\
		$(txIn),\
		$(LOCAL_KEY_DIR)/stake.cert,\
		$(LOCAL_KEY_DIR)/payment.skey $(LOCAL_KEY_DIR)/stake.skey,\
		$(remaining_amount), $(slot), $(fee))

.PHONY: delegate-tx-fee
delegate-tx-fee: ## gets minimum fee for the given delegate tx
	@$(call tx/fee,$(txIn),$(NODE_KEY_DIR)/pool-registration.cert $(NODE_KEY_DIR)/delegation.cert)

local-sign-delegate-tx:
	@$(call tx/sign,\
		$(txIn),\
		$(LOCAL_KEY_DIR)/pool-registration.cert $(LOCAL_KEY_DIR)/delegation.cert,\
		$(LOCAL_KEY_DIR)/payment.skey $(LOCAL_KEY_DIR)/stake.skey $(LOCAL_KEY_DIR)/cold.skey,\
		$(remaining_amount),$(slot),$(fee))

check-pool-created:
	cardano-cli query ledger-state --mary-era --$(NETWORK)$(NETWORK_PARAMETER) | grep $(pool_id)