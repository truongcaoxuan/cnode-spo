#!/bin/bash
mkdir -p $HOME/git

# set up packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install autoconf automake build-essential curl g++ git jq libffi-dev libgmp-dev libncursesw5 libssl-dev libsystemd-dev libtinfo-dev libtool make pkg-config tmux wget zlib1g-dev -y


# set up ghcup
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
[ -f "${HOME}/.ghcup/env" ] && source "${HOME}/.ghcup/env"
ghcup install ghc 8.10.7
ghcup install cabal 3.6.2.0
ghcup set ghc 8.10.7
ghcup set cabal 3.6.2.0


# set up libsodium
cd $HOME/git
git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
sudo make install


# set up secp256k1
cd $HOME/git
git clone https://github.com/bitcoin-core/secp256k1
cd secp256k1
git checkout ac83be33
./autogen.sh
./configure --enable-module-schnorrsig --enable-experimental
make
make check
sudo make install
sudo ldconfig

echo 'export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"' >> ~/.bashrc
echo 'export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"' >> ~/.bashrc
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"


# set up cardano-node, cardano-cli
cd $HOME/git
git clone https://github.com/input-output-hk/cardano-node.git

cd $HOME/git/cardano-node
git fetch --all --recurse-submodules --tags
git checkout $(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)

cd $HOME/git/cardano-node
cabal update
cabal build cardano-node cardano-cli
sudo cp -p "$(./scripts/bin-path.sh cardano-node)" /usr/local/bin/cardano-node
sudo cp -p "$(./scripts/bin-path.sh cardano-cli)" /usr/local/bin/cardano-cli