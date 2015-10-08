# ethic-contracts
This repository contains contracts for Ethic.


## Installation

### Ethereum installation

This assumes that you have [brew](http://brew.sh/) installed:
```bash
$ brew tap ethereum/ethereum
$ brew install ethereum --devel
```

### Repository installation

This repository relies on nodeJS and gulp. You just need to do the following:
```bash
$ npm install -g gulp
$ npm install .
```


### Configuration

In the `bin/` folder you'll find a number of scripts. Each of them rely on configuration files,
that you can find in the `config/` folder. You can generate the config files from the templates using:
```bash
$ gulp install
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
$ ./bin/run.sh
```

## Creating the contract

Simply call `gulp` in the repository folder and it will build the contract configuration file (`contract.json`)
and a javascript template (`create_contract.js`) that you can use to create the contract on the network.

To create the contract, you need to start geth with the following:
```bash
$ ./bin/run.sh
```
Copy-paste the builded javascript in `build/create_contract.js`. After contact is created, you get the contact address, that you can use to build another template `contract.json` that will output the contract ABI and address in JSON:
```bash
$ gulp contract-json -a <address>
```
