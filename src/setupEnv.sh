#!/bin/bash

function createFiles() {
    mkdir network/configtx
	
    touch network/compose/compose-net.yaml
    touch network/compose/docker/docker-compose-net.yaml
    touch network/compose/compose-couch.yaml
    touch network/compose/compose-ca.yaml
    touch network/organizations/cryptogen/crypto-config-orderer.yaml
    touch network/configtx/configtx.yaml
    touch network/organizations/fabric-ca/ordererOrg/fabric-ca-server-config.yaml
    touch network/network.sh
    touch network/organizations/fabric-ca/registerEnroll.sh
    touch network/scripts/envVar.sh
    touch network/scripts/createChannel.sh
    touch network/scripts/deployCC.sh	
}

function setUp() {
    createFiles
    find . -type f -iname "*.sh" -exec chmod +x {} \;
    ./install-fabric.sh docker binary 
    find ./bin -type f -iname "*" -exec chmod +x {} \; #set perms ./bin
    find . -type f -print0 | xargs -0 dos2unix
}

function deleteFiles() {
    # fabric-ca
    if compgen -G 'organizations/fabric-ca/org*' > /dev/null; then
        rm -r organizations/fabric-ca/org*
    fi

    # cryptogen
    if compgen -G 'organizations/cryptogen/crypto-config-org*' > /dev/null; then # BUG
        rm -r organizations/cryptogen/crypto-config-org*
    fi
}

if [ "$1" == "setup" ]; then
	setUp
fi
