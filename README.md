# ethic-contracts
This repository contains contracts for Ethic.


## Installation

### Docker installation

Install docker using instructions [here](https://docs.docker.com/engine/installation/mac/).

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

### Building

Then you can build the docker image using the following:
```bash
$ ./bin/build_docker.sh
```

## Running

To run the docker image in a container, simply use the following:
```bash
$ ./bin/run_docker.sh
```

## Creating the contract

Simply call `gulp` in the repository folder and it will build the contract configuration file (`contract.json`)
and a javascript template (`create_contract.js`) that you can use to create the contract on the network.

To create the contract, you need to start the docker container:
```bash
$ ./bin/run_docker.sh
```
Copy-paste the builded javascript in `build/create_contract.js`. After contact is created, you get the contact address, that you can use to build another template `contract.json` that will output the contract ABI and address in JSON:
```bash
$ gulp contract-json -a <address>
```
