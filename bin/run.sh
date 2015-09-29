#!/usr/bin/env bash
ROOT_DIR=`readlink -f "$(dirname "$(dirname "$0")")" 2> /dev/null` || ROOT_DIR=`pwd`
PASSWORD_FILE=$ROOT_DIR/config/password
LOG_FILE=$ROOT_DIR/logs/mining.log
RPCAPI="eth,personal,web3"

geth --rpc \
     --rpcapi=$RPCAPI \
     --unlock=0 \
     --password=$PASSWORD_FILE \
     --mine \
     console 2> $LOG_FILE
