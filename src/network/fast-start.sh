#!/bin/bash

ORGS=$1

./network.sh up createChannel -ca

local_MSP="'Org1MSP.peer'"

org=2
while [ $org -ne $(($ORGS+1)) ] 
do
	append=",'Org${org}MSP.peer'"
	local_MSP=$local_MSP$append
	org=$(($org+1))
done

./network.sh deployCC -ccn auction -ccp ../auction/auction-simple/chaincode-go/ -ccl go -ccep "OR(${local_MSP})"
