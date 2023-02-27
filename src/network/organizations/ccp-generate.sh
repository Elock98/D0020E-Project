#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORGS=$1
shift
port_51=()
port_54=()

for par in "$@";
do
    if [[ $par =~ .*"51".* ]]; then
        port_51+=("$par")
    else
        port_54+=("$par")
    fi
done

i=1
while [ $i -ne $(($ORGS+1)) ] 
do
    ORG=$i
    P0PORT=${port_51[$i -1]}
    CAPORT=${port_54[$i -1]}
    PEERPEM=organizations/peerOrganizations/org$ORG.example.com/tlsca/tlsca.org$ORG.example.com-cert.pem
    CAPEM=organizations/peerOrganizations/org$ORG.example.com/ca/ca.org$ORG.example.com-cert.pem

    echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org$ORG.example.com/connection-org$ORG.json
    echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org$ORG.example.com/connection-org$ORG.yaml

    i=$(($i+1))
done
