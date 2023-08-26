#!/bin/bash

cd ${NODE_ENVIRON}
NETWORK=preprod

# LocalRoots: This section contains the configuration for the local roots of the node, which are the nodes that the node considers as "local" and will try to connect to first. The local roots are grouped by valency, which is the number of nodes that the node will try to connect to in each group.
# PublicRoots: This section contains the configuration for the public roots of the node, which are the nodes that the node considers as "public" and will try to connect to if it can't connect to any local roots.
# useLedgerAfterSlot: This field indicates the minimum slot number after which the node should switch from using the local copy of the ledger to the copy from the network.
curl -O -J https://book.world.dev.cardano.org/environments/${NETWORK}/topology.json

# This is a configuration file for a Cardano node. 
# It contains various settings that are used to configure the node's behavior and behavior of the network it is connected to.
curl -O -J https://book.world.dev.cardano.org/environments/${NETWORK}/config.json

# The genesis block is the first block of the blockchain and it contains the initial set of rules and parameters for the blockchain. 
# It is the foundation of the blockchain on which all subsequent blocks are built.
# The genesis block is also associated with a configuration file called "shelley-genesis.json" which contains the initial configuration of the blockchain. 
# This file defines the initial set of parameters for the blockchain such as the initial set of validators, the initial distribution of funds, and the initial set of rules and protocols

# Byron era is the first era of the Cardano blockchain, which focuses on building a stable and secure blockchain infrastructure. The Byron era is characterized by the introduction of a new consensus algorithm called Ouroboros Classic, which is based on proof-of-work (PoW) and enables the blockchain to be more secure. The Byron era also includes the introduction of a new wallet and a new blockchain explorer, which makes it easier for users to interact with the blockchain.
curl -O -J https://book.world.dev.cardano.org/environments/${NETWORK}/byron-genesis.json

# Shelley era is the second era of the Cardano blockchain, which focuses on decentralization and community-driven development. The Shelley era is characterized by the introduction of a new consensus algorithm called Ouroboros Genesis, which is based on proof-of-stake (PoS) and enables the blockchain to be more decentralized. The Shelley era also includes the introduction of a new governance model, which allows the community to vote on protocol upgrades and changes.
curl -O -J https://book.world.dev.cardano.org/environments/${NETWORK}/shelley-genesis.json

# Alonzo era is the third era of the Cardano blockchain, which focuses on smart contract functionality and the ability to execute code on the blockchain. The Alonzo era is characterized by the introduction of a new programming language called Plutus and the addition of smart contract functionality to the Cardano blockchain. This allows developers to create decentralized applications (dApps) and allows for more advanced use cases on the blockchain.
curl -O -J https://book.world.dev.cardano.org/environments/${NETWORK}/alonzo-genesis.json

# In summary, Shelley, Byron, and Alonzo are different eras of the Cardano blockchain development, each era focuses on different aspects of the blockchain such as security, decentralization, and smart contract