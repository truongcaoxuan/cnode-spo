#!/bin/bash
mkdir -p \
  $HOME/cardano \
  $HOME/cardano/tmp \
  $HOME/cardano/hot \
  $HOME/cardano/cold \
  $HOME/cardano/util \
  $HOME/cardano/environments

echo 'export CARDANO_NODE_SOCKET_PATH="$HOME/cardano/db/socket"' >> ~/.bashrc
echo 'export NODE_HOME="$HOME/cardano"' >> ~/.bashrc
echo 'export NODE_TMP="$HOME/cardano/tmp"' >> ~/.bashrc
echo 'export NODE_HOT="$HOME/cardano/hot"' >> ~/.bashrc
echo 'export NODE_COLD="$HOME/cardano/cold"' >> ~/.bashrc
echo 'export NODE_UTIL="$HOME/cardano/util"' >> ~/.bashrc
echo 'export NODE_ENVIRON="$HOME/cardano/environments"' >> ~/.bashrc
echo 'export NODE_NETWORK="--testnet-magic 1"' >> ~/.bashrc
echo 'export NODE_CONFIG="testnet"' >> ~/.bashrc

# source ~/.bashrc