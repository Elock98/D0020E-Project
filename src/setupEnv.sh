#!/bin/bash

function setUp() {
    find . -type f -iname "*.sh" -exec chmod +x {} \;
    ./install-fabric.sh docker binary 
    find ./bin -type f -iname "*" -exec chmod +x {} \; #set perms ./bin
    #find . -type f -print0 | xargs -0 dos2unix
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
