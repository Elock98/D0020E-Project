# Network

## Requirements

 - Unix-based system
 - [Docker](https://www.docker.com/)
 - [Fabric prereqs](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html)
 - [Golang](https://go.dev/doc/install)

## Usage

### Setup Script

The idea behind the script is to generate network config files and scripts for a specified number of organizations with one peer node each.

This is accomplished by mostly reading template files and writing to specified files accordingly.

The script can run by simply running
```
./setup.sh
```
Note that it's defaulted to 2 orgs.

Or you can specify the number of organizations by
```
./setup.sh -o <number>
```

### Network Script

You can run the following to deploy the network.

Fast start and the manual start does the same thing.

#### **Fast start**

```
./fast-start.sh <number>
```

The number of orgs must be the same for both network setup and network start.

#### **Manuel start**

(Default 2 orgs)

Start the network using cryptogen, this creates crypto material that each organization uses to identify themselves on the network.
```
./network.sh up 
``` 

Shuts down the network.
```
./network.sh down
``` 

Restart network. First runs network down then up.
```
./network.sh restart 
``` 

Start the network using certificate authorities. This is an alternate method in creating the crypto material.
```
./network.sh up -ca
``` 

Creates a channel (default name "mychannel") and join organization peers to channel.
```
./network.sh up createChannel

opt:
./network.sh up createChannel -c <name>
``` 

Deploy chaincode on channel with a specified signature policy.
```
./network.sh deployCC -ccn auction -ccp <path to chaincode> -ccl go -ccep "<signature-policy>"
``` 

Note the "signature-policy" of the command above, for more information refer to [this page](https://hyperledger-fabric.readthedocs.io/en/latest/endorsement-policies.html).

## Tests

The network has been configured, setup and verified to be working for up to 15 organizations at the same time.

There is also a test script that checks if the setup script generates the expected outcome for 2 and 4 organizations. This test script is located under the ***src/test/*** directory.

## Potential Risks

One noteworthy potential limitation of the setup script is that some of the ports used are generated with an incremental value of up to 2000 or more. This may result in a shortage in ports when generating ports for large amount of organizations.
