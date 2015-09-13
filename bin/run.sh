#!/usr/bin/env bash
ROOT_DIR=`readlink -f "$(dirname "$(dirname "$0")")" 2> /dev/null` || ROOT_DIR=`pwd`
DATADIR=~/.ethereum/test-datachain
GENESIS=$ROOT_DIR/config/genesis.json
ENV_FILE=$ROOT_DIR/config/env

# options
MINE=
CONSOLE=

while [[ $# > 0 ]]; do
  key="$1"

  case $key in
    -m|--mine)
    MINE='--mine --minerthreads=1'
    ;;
    -c|--console)
    CONSOLE="console"
    ;;
    *)
      # unknown option
    ;;
  esac
  shift # past argument or value
done

. $ENV_FILE && geth --networkid=$NETWORK_ID --rpc --maxpeers=0 --genesis=$GENESIS --datadir=$DATADIR $MINE $CONSOLE