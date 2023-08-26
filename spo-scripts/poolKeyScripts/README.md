# Cardano SPO Key Scripts

Scripts for creating and rotating Cardano SPO block-producing keys.

**This repo and the [companion Miro board](https://miro.com/app/board/uXjVOOPT35Y=/) are COMPANION documentation to (not replacement of) the excellent
[CoinCashew](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node) guide.**

More specifically, these scripts and the Miro board cover the following sections of the CoinCashew guide: 

  9. [Generate block-producer keys](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#9.-generate-block-producer-keys)
  10. [Setup payment and stake keys](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#10.-setup-payment-and-stake-keys)
  11. [Register your stake address](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#11.-register-your-stake-address)
  12. [Register your stake pool](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#12.-register-your-stake-pool)

## Miro Board Diagram

See [Cardano Stake Pool Keys](https://miro.com/app/board/uXjVOOPT35Y=/) on Miro for a visual representation of how 
these scripts work. The big numbers in blue circles correspond to the scripts of the same number: 

  - 1 = initialization
  - 2 = rotate block producer KES key
  - 3 = register stake address
  - 4 = register stake pool

## Warning

These scripts are mainly automation with a little bit of documentation. 
These scripts cannot replace having a firm understanding of the operations. 
It is imperative you study the scripts, 
study the [CoinCashew](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node) documentation, 
and become comfortable with the script operations. 

I recommend you play with the scripts and run them a few times until you feel comfortable. 
Don't expect to create production keys on the first try. 

NOTE: Step 4.3 has two scripts - run 4.3a the first time you register the stake pool, and run 4.3b subsequently when updating
pool information.

## Requirements
  - must be run on a node with cardano-cli
  - requires hot and cold nodes, although a single node can act as both hot+cold node 
    if security is not a concern.

## Install
  - edit `config` to set the network and directories
  - edit `4.2-cold-register_pool`; set your margin, pledge, and server information
  - Edit `poolMetaData.json` - see https://developers.cardano.org/docs/stake-pool-course/handbook/register-stake-pool-metadata/
  - Edit `poolMetaData.url` - containing a URL where people can download the aforementioned poolMetaData.json file.
  - Edit `poolMetaData-extended.json` - see https://developers.cardano.org/docs/governance/cardano-improvement-proposals/cip-0006/
  - Copy these files onto 
      - offline (cold) node 
      - online (hot) block producer. Wait for the block producer to be in sync with the network.
  - On the hot node, create a symlink (or copy) called 'shelley-genesis.json' pointing
    to a copy of the <network>-shelley-genesis.json for your network.

## Usage
  - Run the scripts in the order they are numbered. 
  - 1.* should only be run once, to setup and verify your environment
  - Three directories will be created: 
    - `hot` = files which belong on the hot node. 
    - `cold` = files which belong on the cold node, and must never leave the cold node. 
    - `share` = files which must be transferred between the hot and cold node. EG: to sign transactions. 

## FAQ

Q: I ran the scripts, I have stake pool keys, and my pool is registerd. How do I update the pool registration to change rates, metadata, etc?

A: Re-run the 4.* scripts, but use 4.3b (not 4.3a). You don't have to pay the 500 Ada fee again. The change takes effect after two epochs.


