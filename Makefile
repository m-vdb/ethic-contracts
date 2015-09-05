ifndef VERBOSE
.SILENT:
endif

MAIN_SOL = ./main.sol
BUILD_DIR = ./build
MAIN_CONTRACT = ethic_main
OUTPUT_FILE = ${MAIN_CONTRACT}.opcode

all:
	solc ${MAIN_SOL} --opcodes file
	mv ${OUTPUT_FILE} ${BUILD_DIR}
	echo 'Builded file in ${BUILD_DIR}/${OUTPUT_FILE}'
