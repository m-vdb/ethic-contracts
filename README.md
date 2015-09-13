# ethic-contracts
This repository contains contracts for Ethic.


## Installation

### Ethereum installation

This assumes that you have [brew](http://brew.sh/) installed:
```bash
$ brew tap ethereum/ethereum
$ brew install ethereum --devel
```

### Configuration

In the `bin/` folder you'll find a number of scripts. Each of them rely on configuration files,
that you can find in the `config/` folder. You can generate the config files from the templates using:
```bash
$ make install
```
Then, edit `config/env` and provide a networkid (used for `geth` as a test network).
Once done, you can do the following:
```bash
$ ./bin/init.sh
```
This will create a new account for you, and return your ethereum address. Copy it and
write it in the `config/genesis.json` file.

Once done, you can start mining:
```bash
$ ./bin/run.sh --mine
```

## Building the contract

Simply call `make` in the repository folder and it will build the opcodes.
