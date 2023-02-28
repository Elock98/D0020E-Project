#!/bin/bash

OK_C='\033[0;32m'
ERR_C='\033[0;31m'
MSG_C='\033[0;34m'
NO_C='\033[0m'

function checkFiles(){
    # Takes logstring as $1

    echo -e -n ${MSG_C}$1${NO_C}
    if cmp --silent -- "$file1" "$file2"; then
        echo -e " ${OK_C}Ok${NO_C}"
    else
        echo -e " ${ERR_C}Err${NO_C}"
    fi
}

echo "--------------Checking network setup for 2 orgs--------------"

cd ../network
. setup.sh -o 2

cd ../test



file1="target/network/compose-ca-target2.yaml"
file2="../network/compose/compose-ca.yaml"
checkFiles "Checking compose-ca for 2 orgs"

file1="target/network/compose-couch-target2.yaml"
file2="../network/compose/compose-couch.yaml"
checkFiles "Checking compose-couch for 2 orgs"

file1="target/network/compose-net-target2.yaml"
file2="../network/compose/compose-net.yaml"
checkFiles "Checking compose-net for 2 orgs"

file1="target/network/configtx-target2.yaml"
file2="../network/configtx/configtx.yaml"
checkFiles "Checking configtx for 2 orgs"

file1="target/network/createChannel-target2.sh"
file2="../network/scripts/createChannel.sh"
checkFiles "Checking createChannel for 2 orgs"

file1="target/network/crypto-config-orderer-target2.yaml"
file2="../network/organizations/cryptogen/crypto-config-orderer.yaml"
checkFiles "Checking crypto-config-orderer for 2 orgs"

file1="target/network/deployCC-target2.sh"
file2="../network/scripts/deployCC.sh"
checkFiles "Checking deployCC for 2 orgs"

file1="target/network/docker-compose-net-target2.yaml"
file2="../network/compose/docker/docker-compose-net.yaml"
checkFiles "Checking docker-compose-net for 2 orgs"

file1="target/network/envVar-target2.sh"
file2="../network/scripts/envVar.sh"
checkFiles "Checking envVar for 2 orgs"

file1="target/network/fabric-ca-server-config-target2.yaml"
file2="../network/organizations/fabric-ca/ordererOrg/fabric-ca-server-config.yaml"
checkFiles "Checking fabric-ca-server-config for 2 orgs"

file1="target/network/network-target2.sh"
file2="../network/network.sh"
checkFiles "Checking network for 2 orgs"

file1="target/network/registerEnroll-target2.sh"
file2="../network/organizations/fabric-ca/registerEnroll.sh"
checkFiles "Checking registerEnroll for 2 orgs"

echo "--------------Checking network setup for 4 orgs--------------"

cd ../network
. setup.sh -o 4

cd ../test



file1="target/network/compose-ca-target4.yaml"
file2="../network/compose/compose-ca.yaml"
checkFiles "Checking compose-ca for 4 orgs"

file1="target/network/compose-couch-target4.yaml"
file2="../network/compose/compose-couch.yaml"
checkFiles "Checking compose-couch for 4 orgs"

file1="target/network/compose-net-target4.yaml"
file2="../network/compose/compose-net.yaml"
checkFiles "Checking compose-net for 4 orgs"

file1="target/network/configtx-target4.yaml"
file2="../network/configtx/configtx.yaml"
checkFiles "Checking configtx for 4 orgs"

file1="target/network/createChannel-target4.sh"
file2="../network/scripts/createChannel.sh"
checkFiles "Checking createChannel for 4 orgs"

file1="target/network/crypto-config-orderer-target4.yaml"
file2="../network/organizations/cryptogen/crypto-config-orderer.yaml"
checkFiles "Checking crypto-config-orderer for 4 orgs"

file1="target/network/deployCC-target4.sh"
file2="../network/scripts/deployCC.sh"
checkFiles "Checking deployCC for 4 orgs"

file1="target/network/docker-compose-net-target4.yaml"
file2="../network/compose/docker/docker-compose-net.yaml"
checkFiles "Checking docker-compose-net for 4 orgs"

file1="target/network/envVar-target4.sh"
file2="../network/scripts/envVar.sh"
checkFiles "Checking envVar for 4 orgs"

file1="target/network/fabric-ca-server-config-target4.yaml"
file2="../network/organizations/fabric-ca/ordererOrg/fabric-ca-server-config.yaml"
checkFiles "Checking fabric-ca-server-config for 4 orgs"

file1="target/network/network-target4.sh"
file2="../network/network.sh"
checkFiles "Checking network for 4 orgs"

file1="target/network/registerEnroll-target4.sh"
file2="../network/organizations/fabric-ca/registerEnroll.sh"
checkFiles "Checking registerEnroll for 4 orgs"
