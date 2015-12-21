#!/usr/bin/env bash
pushd `dirname $0` > /dev/null
DOCKER_ROOT_DIR=`pwd`
popd > /dev/null
GENESIS=$DOCKER_ROOT_DIR/genesis.json
PASSWORD_FILE=$DOCKER_ROOT_DIR/password
LOG_FILE=$DOCKER_ROOT_DIR/mining.log
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

geth --networkid=2101989 \
     --rpc \
     --rpcaddr="0.0.0.0" \
     --rpcapi=$RPCAPI \
     --maxpeers=0 \
     --gasprice="50" \
     --genesis=$GENESIS \
     --unlock=0 \
     --password=$PASSWORD_FILE \
     --mine \
     --minerthreads=1 \
     $DEBUG console 2> $LOG_FILE
