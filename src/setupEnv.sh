#!/bin/bash

#
# Create necessary files and folders
function createFiles() {
    mkdir network/configtx
    mkdir auction/auction-simple/application-javascript/wallet
    mkdir bin/

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

    touch auction/test-application/javascript/AppUtil.js
    touch auction/auction-simple/application-javascript/bid.js    
    touch auction/auction-simple/application-javascript/closeAuction.js    
    touch auction/auction-simple/application-javascript/createAuction.js    
    touch auction/auction-simple/application-javascript/endAuction.js    
    touch auction/auction-simple/application-javascript/enrollAdmin.js    
    touch auction/auction-simple/application-javascript/queryAuction.js    
    touch auction/auction-simple/application-javascript/queryBid.js    
    touch auction/auction-simple/application-javascript/registerEnrollUser.js    
    touch auction/auction-simple/application-javascript/revealBid.js    
    touch auction/auction-simple/application-javascript/submitBid.js    
}

# 
# set executable permission for shell files & binary files
# install fabric docker images and binaries
function setUp() {
    createFiles
    find . -type f -iname "*.sh" -exec chmod +x {} \;
    ./install-fabric.sh docker binary 
    find ./bin -type f -iname "*" -exec chmod +x {} \; #set perms ./bin
    find . -type f -print0 | xargs -0 dos2unix # converts file encoding from dos to unix, only need for WSL
}

#
# Network tool for cleaning up files
function deleteFiles() {
    # fabric-ca
    if compgen -G 'organizations/fabric-ca/org*' > /dev/null; then
        rm -r organizations/fabric-ca/org*
    fi

    # cryptogen
    if compgen -G 'organizations/cryptogen/crypto-config-org*' > /dev/null; then
        rm -r organizations/cryptogen/crypto-config-org*
    fi

    # wallet
    if compgen -G '../auction/auction-simple/application-javascript/wallet/org*' > /dev/null; then
        rm -r ../auction/auction-simple/application-javascript/wallet/org*
    fi
}

if [ "$1" == "setup" ]; then
	setUp
fi
