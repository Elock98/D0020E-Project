echo -n '' > compose/compose-net.yaml
echo -n '' > compose/docker/docker-compose-net.yaml
echo -n '' > compose/compose-couch.yaml
echo -n '' > compose/compose-ca.yaml
echo -n '' > organizations/cryptogen/crypto-config-orderer.yaml
echo -n '' > organizations/cryptogen/crypto-config-org1.yaml
echo -n '' > organizations/cryptogen/crypto-config-org2.yaml
echo -n '' > configtx/configtx.yaml
echo -n '' > organizations/fabric-ca/ordererOrg/fabric-ca-server-config.yaml
echo -n '' > organizations/fabric-ca/org1/fabric-ca-server-config.yaml
echo -n '' > organizations/fabric-ca/org2/fabric-ca-server-config.yaml
echo -n '' > network.sh

# ---- cocc ----
networkName="test"

function writeTo() {
    while IFS= read -r line; do 
        if [[ $line =~ .*"#VARIABLE#".* ]]; then #change variable
            ws="${line%%[![:space:]]*}"
            echo -n "$ws" >> $output
            eval echo "$line" >> $output
        else #normal write
            echo "$line" >> $output
        fi
    done < $input
}

# -------- Set up network.sh ./ --------
output=network.sh
input=templates/network/createNet.txt

ORGNAME=org1
ORGNAME_TEMP=org2
ORDERERNAME=orderer

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
container_name=peer0.org1.example.com
CORE_PEER_ID=peer0.org1.example.com
CORE_PEER_ADDRESS=peer0.org1.example.com:7051
CORE_PEER_LISTENADDRESS=0.0.0.0:7051
CORE_PEER_CHAINCODEADDRESS=peer0.org1.example.com:7052
CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051
CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
CORE_PEER_LOCALMSPID=Org1MSP
CORE_OPERATIONS_LISTENADDRESS=peer0.org1.example.com:9444
CHAINCODE_AS_A_SERVICE_BUILDER_CONFIG='{"peername":"peer0org1"}'
PORTONE=7051:7051
PORTTWO=9444:9444
VolONE=../organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com:/etc/hyperledger/fabric
VolTWO=peer0.org1.example.com:/var/hyperledger/production

input=templates/compose/docker-compose-template-peer.txt
writeTo

#peer
container_name=peer0.org2.example.com
CORE_PEER_ID=peer0.org2.example.com
CORE_PEER_ADDRESS=peer0.org2.example.com:9051
CORE_PEER_LISTENADDRESS=0.0.0.0:9051
CORE_PEER_CHAINCODEADDRESS=peer0.org2.example.com:9052
CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:9052
CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org2.example.com:9051
CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.example.com:9051
CORE_PEER_LOCALMSPID=Org2MSP
CORE_OPERATIONS_LISTENADDRESS=peer0.org2.example.com:9445
CHAINCODE_AS_A_SERVICE_BUILDER_CONFIG='{"peername":"peer0org2"}'
PORTONE=9051:9051
PORTTWO=9445:9445
VolONE=../organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com:/etc/hyperledger/fabric
VolTWO=peer0.org2.example.com:/var/hyperledger/production

input=templates/compose/docker-compose-template-peer.txt
writeTo

#cli
input=templates/compose/docker-compose-template-cli.txt
writeTo

# -------- Set up docker-compose-net.yaml ./compose/docker --------
output=compose/docker/docker-compose-net.yaml
#top
input=templates/container/docker-container-template-const.txt
writeTo

#peer org1
container_name=peer0.org1.example.com

input=templates/container/docker-container-template-peer.txt
writeTo

#peer org2
container_name=peer0.org2.example.com

input=templates/container/docker-container-template-peer.txt
writeTo

#cli
input=templates/container/docker-container-template-cli.txt
writeTo

# -------- Set up docker-ca.yaml ./compose --------
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