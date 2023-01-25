echo -n '' > compose/docker-compose.yaml
echo -n '' > compose/compose-couch.yaml
echo -n '' > compose/compose-ca.yaml
echo -n '' > compose/docker/docker-compose.yaml

# ---- cocc ----
networkName="test"


# ---- ball ----

function writeTo() {
    while IFS= read -r line; do 
        ws="${line%%[![:space:]]*}"
        echo -n "$ws" >> $output
        eval echo "$line" >> $output
    done < $input
}

# Set up docker-compose.yml ./compose
output=compose/docker-compose.yaml
input=templates/compose/docker-compose-template-const.txt
writeTo
input=templates/compose/docker-compose-template-orderer.txt
writeTo
input=templates/compose/docker-compose-template-peer.txt
writeTo
input=templates/compose/docker-compose-template-cli.txt
writeTo

# Set up docker-compose.yml ./compose/docker
output=compose/docker/docker-compose.yaml
input=templates/container/docker-container-template-const.txt
writeTo
input=templates/container/docker-container-template-peer.txt
writeTo
input=templates/container/docker-container-template-cli.txt
writeTo

# Set up docker-ca ./compose
output=compose/compose-ca.yaml
input=templates/compose/docker-compose-template-const.txt
writeTo
input=templates/compose-ca/compose-ca-template.txt
writeTo
input=templates/compose-ca/compose-ca-orderer-template.txt
writeTo

# Set up docker-couch ./compose
output=compose/compose-couch.yaml
input=templates/compose/docker-compose-template-const.txt
writeTo
input=templates/compose-couch/compose-couch-template.txt
writeTo

# Set up cryptogen orderer ./organizations/cryptogen
output=organizations/cryptogen/crypto-config-orderer.yaml
input=templates/cryptogen/crypto-config-orderer-template.txt
writeTo

# Set up cryptogen org ./organizations/cryptogen
output=organizations/cryptogen/crypto-config-org.yaml
input=templates/cryptogen/crypto-config-org-template.txt
writeTo