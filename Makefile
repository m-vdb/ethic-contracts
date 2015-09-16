ifndef VERBOSE
.SILENT:
endif

MAIN_SOL = ./main.sol
BUILD_DIR = ./build
MAIN_CONTRACT = ethic_main
OUTPUT_FILE = ${MAIN_CONTRACT}.binary

all:
	solc ${MAIN_SOL} --binary file
	mv ${OUTPUT_FILE} ${BUILD_DIR}
	echo 'Builded file in ${BUILD_DIR}/${OUTPUT_FILE}'

install:
	cp config/env.tpl config/env
	cp config/genesis.json.tpl config/genesis.json
