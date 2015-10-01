#!/usr/bin/env bash
ROOT_DIR=`readlink -f "$(dirname "$(dirname "$0")")" 2> /dev/null` || ROOT_DIR=`pwd`
DATADIR=~/.ethereum/test-datachain
GENESIS=$ROOT_DIR/config/genesis.json
ENV_FILE=$ROOT_DIR/config/env
PASSWORD_FILE=$ROOT_DIR/config/password
LOG_FILE=$ROOT_DIR/logs/mining.log
RPCAPI="eth,personal,web3"

# options
DEBUG=

while [[ $# > 0 ]]; do
  key="$1"

  case $key in
    -d|--debug)
    DEBUG='--verbosity 6'
    ;;
    *)
      # unknown option
    ;;
  esac
  shift # past argument or value
done

. $ENV_FILE &&
geth --networkid=$NETWORK_ID \
     --rpc \
     --rpcapi=$RPCAPI \
     --maxpeers=0 \
     --gasprice="50" \
     --genesis=$GENESIS \
     --datadir=$DATADIR \
     --unlock=0 \
     --password=$PASSWORD_FILE \
     --mine \
     --minerthreads=1 \
     $DEBUG console 2> $LOG_FILE
