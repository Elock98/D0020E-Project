#!/bin/bash

# Clear all files thats written to
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
echo -n '' > scripts/deployCC.sh


# ---- Global variables ----
networkName="test"
total_orgs=2
peers_per_org=1
org_id=1
peer_id=0

RE_PORTS=()
peer_port_51=()

ALL_PEERS_NO_HYPHEN=()
ALL_PEERS_HYPHEN=()
CONTAINERS=()

usedPorts=(":9054:" ":19054:") # Array of ports that have been used

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

# ---- Utility Functions ----

function logToTerm() {
    if $(VERBOSE);
    then
        echo "$1"
    fi
}

# ---- Output Functions ----

#
# Variable substitution
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

#
# Main output function
function writeTo() {
    while IFS= read -r line; do
        #
        # If a line in a template needs to be repeated multiple times
        if [[ $line =~ .*"#repeatX#".* ]]; then
            for org_l in $(seq 1 $(($total_orgs)));
            do
                org_id=$org_l
                peer51=${peer_port_51[$org_l -1]}

                # Handeling for specific cases
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
                elif [[ $line =~ .*"#InstallChaincode#".* ]]; then
                    input2=templates/deployCC/installChainCode.txt
                elif [[ $line =~ .*"#queryCommit#".* ]]; then
                    input2=templates/deployCC/queryCommit.txt
                elif [[ $line =~ .*"#orgsDep#".* ]]; then
                    input2=templates/fabric-ca/orgdep.txt
                fi
                writeTo2
            done
        #
        # If a line in a template needs to be appended multiple times
        elif [[ $line =~ .*"#appendX#".* ]]; then
            orgIds=""
            org=1
            while [ $org -ne $(($total_orgs+1)) ] 
            do
                append=" $org"
                orgIds=$orgIds$append
                org=$(($org+1))
            done
        #
        # Specific append case
        elif [[ $line =~ .*"#appendOrgs#".* ]]; then
            orgs=""
            for org_l in $(seq 1 $(($total_orgs)));
            do
                append=" docker_peer0.org${org_l}.example.com"
                orgs=$orgs$append
            done
        fi

        #
        # Normal variable substitution
        if [[ $line =~ .*"#VARIABLE#".* ]];
        then
            ws="${line%%[![:space:]]*}"
            echo -n "$ws" >> $output
            eval echo "$line" >> $output
        #
        # Array substitution
        elif [[ $line =~ .*"#ARRAY#".* ]];
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
        #
        # Write the line as it was in the template
        else
            echo "$line" >> $output
        fi
    done < $input
}

# ---- Setup & Calculate Ports ----

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

for org_l in $(seq 1 $(($total_orgs)));
do
    port=7051
    CheckPort $port 2000
    peer_port_51+=("$port")

    port=7054
    CheckPort $port 1000
    RE_PORTS+=("$port")
done

# ---- Create org-based files & folders ----

. ../setupEnv.sh
deleteFiles

for org_l in $(seq 1 $(($total_orgs)));
do
    mkdir organizations/fabric-ca/org$org_l
    touch organizations/fabric-ca/org$org_l/fabric-ca-server-config.yaml

    touch organizations/cryptogen/crypto-config-org$org_l.yaml
done

# ---- Generate auction files ----

cd ../auction/auction-simple/application-javascript/

. generatecode.sh $total_orgs

cd ../../../network/

# Setup files

# -------- Set up network.sh ./ --------
output=network.sh
input=templates/network/createNet.txt

ORDERERNAME=orderer

writeTo

# -------- Set up organizations/fabric-ca/registerEnroll.sh --------
output=organizations/fabric-ca/registerEnroll.sh
#peer
input=templates/registerEnroll/createOrg.txt

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

# -------- Set up scripts/deployCC.sh --------

output=scripts/deployCC.sh
input=templates/deployCC/deployCC.txt
writeTo

# -------- Set up compose/compose-net.yaml --------
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

# -------- Set up compose/docker/docker-compose-net.yaml --------
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

# -------- Set up compose/compose-ca.yaml --------
output=compose/compose-ca.yaml
input=templates/compose/docker-compose-template-const.txt
writeTo

for org_l in $(seq 1 $(($total_orgs)));
do
    # Calculate port starting from 7054 and 17054
    # increase by 1000 for each collision.
    # Note that we should ignore 9054 and 19054
    # to avoid collision (solved by hardcoding them
    # into the used ports list).
    p1=${RE_PORTS[$org_l -1]}

    port=17054
    CheckPort $port 1000
    p2=$port

    containerNAME=ca_org$org_l
    FABRIC_CA_SERVER_CA_NAME=ca-org$org_l
    FABRIC_CA_SERVER_PORT=$p1
    FABRIC_CA_SERVER_OPERATIONS_LISTENADDRESS=0.0.0.0:$p2
    PORTONE='"'$p1':'$p1'"'
    PORTTWO='"'$p2':'$p2'"'
    VolONE=../organizations/fabric-ca/org$org_l:/etc/hyperledger/fabric-ca-server

    input=templates/compose-ca/compose-ca-template.txt
    writeTo
done

input=templates/compose-ca/compose-ca-orderer-template.txt
writeTo

# -------- Set up compose/docker-couch.yaml --------
output=compose/compose-couch.yaml
input=templates/compose/docker-compose-template-const.txt
writeTo

db_index=0

for org_l in $(seq 1 $(($total_orgs)));
do
    default_port=5984
    port=$default_port
    CheckPort $port 2000

    container_name=couchdb$db_index
    PORTONE='"'$port':'$default_port'"'
    peerName=peer0.org$org_l.example.com
    CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb$db_index:$default_port

    input=templates/compose-couch/compose-couch-template.txt
    writeTo

    db_index=$(($db_index + 1))
done

# -------- Set up organizations/cryptogen/crypto-config-orderer.yaml --------
output=organizations/cryptogen/crypto-config-orderer.yaml
input=templates/cryptogen/crypto-config-orderer-template.txt
writeTo

# -------- Set up cryptogen org ./organizations/cryptogen --------
for org_l in $(seq 1 $(($total_orgs)));
do
    output=organizations/cryptogen/crypto-config-org$org_l.yaml

    NAME=Org$org_l
    DOMAIN=org$org_l.example.com

    input=templates/cryptogen/crypto-config-org-template.txt
    writeTo
done

# -------- Setp up configtx/configtx.yaml --------
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

# -------- Set up fabric-ca for orderer ./organizations/fabric-ca/ordererOrg --------
# For now we assume only one orderer node in the network.

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

# -------- Set up fabric-ca for org ./organizations/fabric-ca/org --------
# All the orgs will be assumed to be located in the same place to
# make the setup simpler.

for org_l in $(seq 1 $(($total_orgs)));
do
    caName="Org${org_l}CA"
    csrCn=ca.org$org_l.example.com
    csrNamesC=US
    csrNamesST='"North Carolina"'
    csrNamesL='"Durham"'
    csrNamesO=org$org_l.example.com
    csrHost=org$org_l.example.com

    output=organizations/fabric-ca/org$org_l/fabric-ca-server-config.yaml
    input=templates/fabric-ca/fabric-ca-server-config-template.txt
    writeTo
done
