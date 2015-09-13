#!/usr/bin/env bash
ROOT_DIR=`readlink -f "$(dirname "$(dirname "$0")")" 2> /dev/null` || ROOT_DIR=`pwd`
ENV_FILE=$ROOT_DIR/config/env
DATADIR=~/.ethereum/test-datachain

. $ENV_FILE && geth --networkid=$NETWORK_ID --datadir=$DATADIR account new
