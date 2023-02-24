#!/bin/bash

echo -n '' > compose/compose-net.yaml
echo -n '' > compose/docker/docker-compose-net.yaml
echo -n '' > compose/compose-couch.yaml
echo -n '' > compose/compose-ca.yaml
echo -n '' > organizations/cryptogen/crypto-config-orderer.yaml
echo -n '' > configtx/configtx.yaml
echo -n '' > organizations/fabric-ca/ordererOrg/fabric-ca-server-config.yaml
echo -n '' > network.sh
echo -n '#!/bin/bash' > organizations/fabric-ca/registerEnroll.sh
echo -n '' > scripts/envVar.sh
echo -n '' > scripts/createChannel.sh


# ---- Global variables ----
networkName="test"
total_orgs=2
peers_per_org=1
org_id=1
peer_id=0

RE_PORTS=("7054" "8054")
peer_port_51=("7051" "9051")

ALL_PEERS_NO_HYPHEN=()
ALL_PEERS_HYPHEN=()
CONTAINERS=()

usedPorts=() # Array of ports that have been used

VERBOSE='false'

# ---- Option parsing ----

while getopts o:p:v option
do
    case "${option}"
    in
        o)total_orgs=${OPTARG};;
        p)peers_per_org=${OPTARG};;
        v)VERBOSE='true';;
    esac

done

# ---- Functions ----
function logToTerm() {
    if $(VERBOSE);
    then
        echo "$1"
    fi
}

function writeTo2() {
    while IFS= read -r line2; do
        if [[ $line2 =~ .*"#VARIABLE#".* ]]; then #change variable
            ws="${line2%%[![:space:]]*}"
            echo -n "$ws" >> $output
            eval echo "$line2" >> $output
        else #normal write
            echo "$line2" >> $output
        fi
    done < $input2
}

function writeTo() {
    while IFS= read -r line; do
        if [[ $line =~ .*"#repeatX#".* ]]; then
            for org_l in $(seq 1 $(($total_orgs)));
            do
                org_id=$org_l
                peer51=${peer_port_51[$org_l -1]}
                if [[ $line =~ .*"#orgCrypto#".* ]]; then
                    input2=templates/network/orgCrypto.txt
                elif [[ $line =~ .*"#orgCA#".* ]]; then
                    input2=templates/network/orgCA.txt
                elif [[ $line =~ .*"#removeOrg#".* ]]; then
                    input2=templates/network/removeOrg.txt
                elif [[ $line =~ .*"#defOrgs#".* ]]; then
                    input2=templates/configtx/createOrg.txt
                elif [[ $line =~ .*"#listOrgs#".* ]]; then
                    input2=templates/configtx/listOrgs.txt
                elif [[ $line =~ .*"#usingOrg#".* ]]; then
                    if [ $org_l == 1 ]; then
                        input2=templates/envVar/ifState.txt
                    else
                        input2=templates/envVar/elifState.txt
                    fi
                    writeTo2
                    input2=templates/envVar/usingOrg.txt
                elif [[ $line =~ .*"#usingOrg2#".* ]]; then
                    if [ $org_l == 1 ]; then
                        input2=templates/envVar/ifState.txt
                    else
                        input2=templates/envVar/elifState.txt
                    fi
                    writeTo2
                    input2=templates/envVar/usingOrg2.txt
                elif [[ $line =~ .*"#exportOrgLink#".* ]]; then
                    input2=templates/envVar/exportOrgLink.txt
                elif [[ $line =~ .*"#JoinPeer#".* ]]; then
                    input2=templates/createChannel/joinPeer.txt
                elif [[ $line =~ .*"#SetAnchorPeer#".* ]]; then
                    input2=templates/createChannel/setAnchorPeer.txt
                fi
                writeTo2
            done
        fi

        if [[ $line =~ .*"#VARIABLE#".* ]]; # Normal variable substitution
        then
            ws="${line%%[![:space:]]*}"
            echo -n "$ws" >> $output
            eval echo "$line" >> $output

        elif [[ $line =~ .*"#ARRAY#".* ]]; # Array substitution
        then
            ws="${line%%[![:space:]]*}"

            # Select array
            case "$line" in
                *ALL_PEERS_NO_HYPHEN*) array=("${ALL_PEERS_NO_HYPHEN[@]}");;
                *ALL_PEERS_HYPHEN*) array=("${ALL_PEERS_HYPHEN[@]}");;
            esac

            for i in ${!array[@]}; do
                echo -n "$ws" >> $output
                eval echo "${array[$i]}" >> $output
            done

        else #Write the line as it was in the template
            echo "$line" >> $output
        fi
    done < $input
}

function CheckPort() {
    # Takes port to check as arg "$1" and increment
    # amount as arg "$2".
    local check_port=$1
    local increment=$2
    while true ;
    do
        if [[ ! "${usedPorts[*]}" =~ ":$check_port:" ]]; then
            # If port is not in the used port array
            # add it to the array and update the
            # port variable.

            port="$check_port"
            usedPorts+=(":$check_port:")
            break

        fi

        # If the port is in the exclusion array
        # get the next port to check
        check_port=$(($check_port + $increment))
    done
}

# ---- Create org-based files & folders ----

. ../setupEnv.sh
deleteFiles

for org_l in $(seq 1 $(($total_orgs)));
do
    mkdir organizations/fabric-ca/org$org_l
    touch organizations/fabric-ca/org$org_l/fabric-ca-server-config.yaml

    touch organizations/cryptogen/crypto-config-org$org_l.yaml
done

# -------- Set up network.sh ./ --------
output=network.sh
input=templates/network/createNet.txt

#org_id=1
#ORGNAME_TEMP=org2
ORDERERNAME=orderer

writeTo

# -------- Set up registerEnroll.sh ./organizations/fabric-ca --------
output=organizations/fabric-ca/registerEnroll.sh
#peer
input=templates/registerEnroll/createOrg.txt

#*RE_PORTS*) array=("${RE_PORTS[@]}");;

for org_l in $(seq 1 $(($total_orgs)));
do
    for peer_l in $(seq 0 $(($peers_per_org -1)));
    do
        peer_id=$peer_l
        org_id=$org_l
        portnum=${RE_PORTS[$org_l -1]}

        writeTo
    done
done


#orderer
input=templates/registerEnroll/createOrderer.txt
writeTo

# -------- Set up compose-net.yaml ./compose --------
output=compose/compose-net.yaml
#top
input=templates/compose/docker-compose-template-const.txt
writeTo
#orderer
input=templates/compose/docker-compose-template-orderer.txt
writeTo

#peer
input=templates/compose/docker-compose-template-peer.txt

for org_l in $(seq 1 $(($total_orgs)));
do
    for peer_l in $(seq 0 $(($peers_per_org -1)));
    do
        peer_id=$peer_l
        org_id=$org_l

        # Set base-port and update it if it's in use
        port=7050
        CheckPort $port 2000

        container_name="peer$peer_id.org$org_id.example.com"
        CORE_PEER_ID="peer$peer_id.org$org_id.example.com"
        CORE_PEER_ADDRESS="peer$peer_id.org$org_id.example.com:$(($port+1))"
        CORE_PEER_LISTENADDRESS=0.0.0.0:"$(($port+1))"
        CORE_PEER_CHAINCODEADDRESS="peer$peer_id.org$org_id.example.com:$(($port+2))"
        CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:"$(($port+2))"
        CORE_PEER_GOSSIP_BOOTSTRAP="peer$peer_id.org$org_id.example.com:$(($port+1))"
        CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer$peer_id.org$org_id.example.com:$(($port+1))"
        CORE_PEER_LOCALMSPID=Org"$org_id"MSP
        CHAINCODE_AS_A_SERVICE_BUILDER_CONFIG='{"peername":"peer'$peer_id'org'$org_id'"}'
        PORTONE=$(($port+1)):$(($port+1))
        VolONE="../organizations/peerOrganizations/org$org_id.example.com/peers/peer$peer_id.org$org_id.example.com:/etc/hyperledger/fabric"
        VolTWO="peer$peer_id.org$org_id.example.com:/var/hyperledger/production"

        # Set base-port and update it if it's in use
        port=9444
        CheckPort $port 1

        CORE_OPERATIONS_LISTENADDRESS="peer$peer_id.org$org_id.example.com:$port"
        PORTTWO=$port:$port

        # Add peer to collection
        ALL_PEERS_NO_HYPHEN+=("$container_name:")
        ALL_PEERS_HYPHEN+=("- $container_name")
        CONTAINERS+=("$container_name")
        writeTo
    done
done

#cli
input=templates/compose/docker-compose-template-cli.txt
writeTo

# -------- Set up docker-compose-net.yaml ./compose/docker --------
output=compose/docker/docker-compose-net.yaml
#top
input=templates/container/docker-container-template-const.txt
writeTo

input=templates/container/docker-container-template-peer.txt

for i in ${!CONTAINERS[@]}; do
    container_name="${CONTAINERS[$i]}"
    writeTo
done

#cli
input=templates/container/docker-container-template-cli.txt
writeTo

# -------- Set up compose-ca.yaml ./compose --------
output=compose/compose-ca.yaml
input=templates/compose/docker-compose-template-const.txt
writeTo

#ca org1
containerNAME=ca_org1
FABRIC_CA_SERVER_CA_NAME=ca-org1
FABRIC_CA_SERVER_PORT=7054
FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:17054
PORTONE='"7054:7054"'
PORTTWO='"17054:17054"'
VolONE=../organizations/fabric-ca/org1:/etc/hyperledger/fabric-ca-server

input=templates/compose-ca/compose-ca-template.txt
writeTo

#ca org2
containerNAME=ca_org2
FABRIC_CA_SERVER_CA_NAME=ca-org2
FABRIC_CA_SERVER_PORT=8054
FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:18054
PORTONE='"8054:8054"'
PORTTWO='"18054:18054"'
VolONE=../organizations/fabric-ca/org2:/etc/hyperledger/fabric-ca-server

input=templates/compose-ca/compose-ca-template.txt
writeTo

input=templates/compose-ca/compose-ca-orderer-template.txt
writeTo

# -------- Set up docker-couch ./compose --------
output=compose/compose-couch.yaml
input=templates/compose/docker-compose-template-const.txt
writeTo

#peer org1
container_name=couchdb0
PORTONE='"5984:5984"'
peerName=peer0.org1.example.com
CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb0:5984

input=templates/compose-couch/compose-couch-template.txt
writeTo

#peer org2
container_name=couchdb1
PORTONE='"7984:5984"'
peerName=peer0.org2.example.com
CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb1:5984

input=templates/compose-couch/compose-couch-template.txt
writeTo

# -------- Set up cryptogen orderer ./organizations/cryptogen --------
output=organizations/cryptogen/crypto-config-orderer.yaml
input=templates/cryptogen/crypto-config-orderer-template.txt
writeTo

# -------- Set up cryptogen org1 ./organizations/cryptogen --------
output=organizations/cryptogen/crypto-config-org1.yaml

NAME=Org1
DOMAIN=org1.example.com

input=templates/cryptogen/crypto-config-org-template.txt
writeTo

# -------- Set up cryptogen org2 ./organizations/cryptogen --------
output=organizations/cryptogen/crypto-config-org2.yaml

NAME=Org2
DOMAIN=org2.example.com

input=templates/cryptogen/crypto-config-org-template.txt
writeTo

# -------- Setp up configtx ./configtx --------
output=configtx/configtx.yaml
input=templates/configtx/configtx-template.txt

writeTo


# -------- Set up scripts/envVar.sh ---------
output=scripts/envVar.sh
input=templates/envVar/envVar.txt
writeTo

# -------- Set up scripts/createChannel.sh ---------
output=scripts/createChannel.sh
input=templates/createChannel/createChannel.txt
writeTo

# -------- Set up fabric-ca for orderer ./organizations/fabric-ca/Orderer --------
caName=OrdererCA
csrCn=ca.example.com
csrNamesC=US
csrNamesST='"New York"'
csrNamesL='"New York"'
csrNamesO=example.com
csrHost=example.com

output=organizations/fabric-ca/ordererOrg/fabric-ca-server-config.yaml
input=templates/fabric-ca/fabric-ca-server-config-template.txt
writeTo

# -------- Set up fabric-ca for org1 ./organizations/fabric-ca/org1 --------
caName=Org1CA
csrCn=ca.org1.example.com
csrNamesC=US
csrNamesST='"North Carolina"'
csrNamesL='"Durham"'
csrNamesO=org1.example.com
csrHost=org1.example.com

output=organizations/fabric-ca/org1/fabric-ca-server-config.yaml
input=templates/fabric-ca/fabric-ca-server-config-template.txt
writeTo

# -------- Set up fabric-ca for org2 ./organizations/fabric-ca/org2 --------
caName=Org2CA
csrNamesC=UK
csrCn=ca.org2.example.com
csrNamesST='"Hampshire"'
csrNamesL='"Hursley"'
csrNamesO=org2.example.com
csrHost=org2.example.com

output=organizations/fabric-ca/org2/fabric-ca-server-config.yaml
input=templates/fabric-ca/fabric-ca-server-config-template.txt
writeTo
