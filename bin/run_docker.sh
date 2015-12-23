#!/usr/bin/env bash
pushd `dirname $0` > /dev/null
CURRENT_DIR=`pwd`
ROOT_DIR=`dirname $CURRENT_DIR`
popd > /dev/null

docker run -it \
  -p 8545:8545 \
  -p 30303:30303 \
  -v $ROOT_DIR/logs:/usr/src/app/logs:rw \
  ethic/ethereum-go
