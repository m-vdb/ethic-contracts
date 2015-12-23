FROM ubuntu:wily
MAINTAINER caktux

ENV DEBIAN_FRONTEND noninteractive

# Usual update / upgrade
RUN apt-get update
RUN apt-get upgrade -q -y
RUN apt-get dist-upgrade -q -y

# Install Ethereum
RUN apt-get install -q -y software-properties-common
RUN add-apt-repository ppa:ethereum/ethereum
RUN add-apt-repository ppa:ethereum/ethereum-dev
RUN apt-get update
RUN apt-get install -q -y geth

# Working directory
RUN mkdir -p /usr/src/app/logs
WORKDIR /usr/src/app

# Copy files
COPY bin/run_geth.sh /usr/src/app/
COPY config/password /usr/src/app/

# Create account and save address
RUN geth --password ./password account new | sed 's/Address: {\([a-f0-9]\+\)}/\1/' > address

# Create genesis
COPY config/genesis.json.tpl /usr/src/app/genesis.json
RUN cat address | xargs -i sed -i 's/<address>/{}/g' genesis.json

EXPOSE 8545
EXPOSE 30303

ENTRYPOINT ["/usr/src/app/run_geth.sh"]
