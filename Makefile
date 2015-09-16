ifndef VERBOSE
.SILENT:
endif

MAIN_SOL = ./main.sol
BUILD_DIR = ./build
MAIN_CONTRACT = ethic_main
BINARY_FILE = ${MAIN_CONTRACT}.binary
ABI_FILE = ${MAIN_CONTRACT}.abi

all: binary abi

binary:
	solc ${MAIN_SOL} --binary file
	mv ${BINARY_FILE} ${BUILD_DIR}
	echo 'Builded file in ${BUILD_DIR}/${BINARY_FILE}'

abi:
	solc ${MAIN_SOL} --json-abi file
	mv ${ABI_FILE} ${BUILD_DIR}
	echo 'Builded file in ${BUILD_DIR}/${ABI_FILE}'

install:
	cp config/env.tpl config/env
	cp config/genesis.json.tpl config/genesis.json
