
function setUp() {
    find . -type f -iname "*.sh" -exec chmod +x {} \;
    find ./bin -type f -iname "*" -exec chmod +x {} \; #set perms ./bin
    ./install-fabric.sh --fabric-version 2.2.1 binary
    find . -type f -print0 | xargs -0 dos2unix
}

function deleteFiles() {
    rm organizations/fabric-ca/org1/ca-cert.pem
    rm organizations/fabric-ca/org2/ca-cert.pem

    rm organizations/fabric-ca/org1/IssuerRevocationPublicKey
    rm organizations/fabric-ca/org2/IssuerRevocationPublicKey
}
