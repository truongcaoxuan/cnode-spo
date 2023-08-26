FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND=noninteractive
ARG OS_ARCH
ARG GHC_VERSION
ARG CABAL_VERSION
ARG LIBSODIUM_VERSION
ARG CARDANO_NODE_VERSION

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev \
    zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf llvm libnuma-dev

# INSTALL GHC
# The Glasgow Haskell Compiler
WORKDIR /build/ghc
RUN wget https://downloads.haskell.org/~ghc/${GHC_VERSION}/ghc-${GHC_VERSION}-${OS_ARCH}-deb10-linux.tar.xz
RUN tar -xf ghc-${GHC_VERSION}-${OS_ARCH}-deb10-linux.tar.xz
RUN cd ghc-${GHC_VERSION} && ./configure && make install

# Install Cabal
RUN wget https://downloads.haskell.org/~cabal/cabal-install-${CABAL_VERSION}/cabal-install-${CABAL_VERSION}-x86_64-unknown-linux.tar.xz && \
    tar -xf cabal-install-${CABAL_VERSION}-x86_64-unknown-linux.tar.xz && \
    rm cabal-install-${CABAL_VERSION}-x86_64-unknown-linux.tar.xz cabal.sig && \
    mkdir -p ~/.local/bin && \
    mv cabal ~/.local/bin/

# Install Libsodium
WORKDIR /build/libsodium
RUN git clone https://github.com/input-output-hk/libsodium
RUN cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && ./configure && make && make install

ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

RUN ~/.local/bin/cabal update

WORKDIR /build/cardano-node
RUN git clone --branch ${CARDANO_NODE_VERSION} https://github.com/input-output-hk/cardano-node.git && \
    cd cardano-node && \
    ~/.local/bin/cabal configure --with-compiler=ghc-8.10.2 && \
    ~/.local/bin/cabal build cardano-node cardano-cli

FROM ubuntu:20.04
ARG OS_ARCH
ARG GHC_VERSION
ARG CARDANO_NODE_VERSION

## Libsodium refs
COPY --from=builder /usr/local/lib /usr/local/lib

## Not sure I still need thse
ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
RUN rm -fr /usr/local/lib/ghc-${GHC_VERSION}

COPY --from=builder /build/cardano-node/cardano-node/dist-newstyle/build/${OS_ARCH}-linux/ghc-${GHC_VERSION}/cardano-node-${CARDANO_NODE_VERSION}/x/cardano-node/build/cardano-node/cardano-node /usr/local/bin/
COPY --from=builder /build/cardano-node/cardano-node/dist-newstyle/build/${OS_ARCH}-linux/ghc-${GHC_VERSION}/cardano-cli-${CARDANO_NODE_VERSION}/x/cardano-cli/build/cardano-cli/cardano-cli /usr/local/bin/

ENTRYPOINT ["bash", "-c"]