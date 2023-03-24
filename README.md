# D0020E - A decentralized on-chain auction system based on signatures and blockchain

This project is part of the course ’D0020E - Project in Computer Science and Engineering’ at Luleå University of Technology. The aims of the course are to expand the students knowledge and understanding of engineering projects.

## The Project

The project assignment has been to create ’A decentralized on-chain auction system based on signatures and blockchain’.  The system should allow a client to connect to a validator network and place an item up for auction. Other clients should be allowed to see the following items that are up for sale and also be able to connect to the validator network and place bids on the sales items. The highest bidder of the auction wins the item.
You can read more about the project [here](https://www.overleaf.com/read/gkmzgnktkyyz)

## Background

The popularity of the internet has increased the use of electronic auctions, which is a model where sellers and buyers compete over assets and rights where the highest bid usually wins. There are different types of auctions, the four most common are the English-, Dutch-, sealed-bid- and double auction.

Currently most electronic auction systems are centralized where a third party is acting like a middle man with a web application. These systems requires that the third party is trustworthy and secure since it needs to keep all the information in a database. If the third party somehow is compromised it could leak privileged information or act bias in an auction, especially in a sealed-bid auction.

One way to avoid these problems is by using a decentralized auction system based on signatures and blockchain where no third party is needed. In a system like this all the participants are connected to a private network where they can create auctions and choose who is allowed to participate. When an auction is complete and a winner is decided a smart contract is written between the auctioneer and the winner. All the data from the auction is saved to a distributed blockchain ledger specifically for that auction.


## The Group
The student group consists of the following four members:

@syko240 - André Roaas androa-0@student.ltu.se \
@Elock98 - Emil Lock emiloc-0@student.ltu.se \
@peggykhialie - Peggy Khialie pegkhi-0@student.ltu.se\
@linseb-9 - Sebastian Lindgren linseb-9@student.ltu.se


## Setup Environment

Follow the link below to set up fabric pre requirements:
[Fabric prereqs](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html).

### Setup Go Environment

Refer to [this page](https://hyperledger-fabric.readthedocs.io/en/latest/install.html) when creating working directory.

### Setup

Then set up the environment by running the script setupEnv.sh
```
cd src
./setupEnv.sh setup
```
When running this script we create necessary files and folders, install fabric binaries, docker images and set executable privileges to all shell files and binaries.

## Network setup

By running the following script we set up all network configuration for set number of organizations as well setting up all auction scripts, refer to [network](src/network/README.md) and [auction](src/auction/auction-simple/application-javascript/README.md).
```
cd network
./setup.sh
```

When running setup the default number of organizations is 2, to specify how many run the following:
(Example, setup for 4 orgs)
```
./setup.sh -o 4
```

## Start the Network

You can run the following to deploy the network.

Fast start and the manual start does the same thing.

### Fast start

(Example, start for 4 orgs)
```
./fast-start.sh 4
```

The number of orgs must be the same for both network setup and network start.

### Manuel start

(Default 2 orgs)

Start by running the following to start up the network with one channel.
```
./network.sh up createChannel -ca
```
The -ca flag starts the network using certificate authorities.

Then we also need to deploy the chaincode.

```
./network.sh ./network.sh deployCC -ccn auction -ccp ../auction/auction-simple/chaincode-go/ -ccl go -ccep "OR('Org1MSP.peer','Org2MSP.peer')"
```
Note the last section of the command above is the endorsement policy, for more information refer to [this page](https://hyperledger-fabric.readthedocs.io/en/latest/endorsement-policies.html).

More information about the network startup can be found [here](src/network/README.md).


## Auction (demo)

(Important: The demo require 4 orgs)

This is a demo for the sealed auction with 4 users: 1 seller and 3 bidders

Enroll orgs as admins.
```
node enrollAdmin.js org1
node enrollAdmin.js org2
node enrollAdmin.js org3
node enrollAdmin.js org4
```
Enroll users, 1 seller and 3 bidders.
```
node registerEnrollUser.js org4 seller
node registerEnrollUser.js org1 bidder1
node registerEnrollUser.js org2 bidder2
node registerEnrollUser.js org3 bidder3
```
Seller from org4 will create a new auction with auctionID: Auction, and item: art.
```
node createAuction.js org4 seller Auction art
```
Now we generate two bids for org1 and submit the first one.

```
node bid.js org1 bidder1 Auction 800
node bid.js org1 bidder1 Auction 600
node submitBid.js org1 bidder1 Auction <BidID>
```
Note that both transactions generate a BidID, save this value because you will need it to submit the bid as well reveal it.

From both generated bids you should see a field "valid", a true or false value. This field will only be false if a bid has already been submitted from the same org.

We will also be trying to make a new bid for org1 and submit the last one that we did not submit and the new which we just created.
```
node bid.js org1 bidder1 Auction 700
node submitBid.js org1 bidder1 Auction <BidID>
node submitBid.js org1 bidder1 Auction <BidID>
```
From the last generated bid we can see in the "valid" field that it's set to false now. And when we tried to submit these bids you should see that both bids are counted as invalid now that org1 has already submitted one valid bid.

Generate and submit a bid for org2.
```
node bid.js org2 bidder2 Auction 500
node submitBid.js org2 bidder2 Auction <BidID>
```
We will not try to close the auction before org3 has submitted a bid.

Note that we need to query the auction because trying to close the auction prematurely wont give an output.
```
node closeAuction.js org4 seller Auction
node queryAuction.js org4 seller Auction
```
You should now see that the auction is still open.

Generate and submit a bid for org3.
```
node bid.js org3 bidder3 Auction 900
node submitBid.js org3 bidder3 Auction <BidID>
```
Now every participating organization has submitted a bid, and instead of having the seller call for a close, the auction will instead automatically close.

Reveal the submitted bids for org1 and org2.
```
node revealBid.js org1 bidder1 Auction <BidID>
node revealBid.js org2 bidder2 Auction <BidID>
```

The seller will now attempt to end the auction.
```
node endAuction.js org4 seller Auction
```
This proposal will be rejected by org3 since org3 have the winning bid.

Reveal the last bid and end the auction.
```
node revealBid.js org3 bidder3 Auction <bidID>
node endAuction.js org4 seller Auction
```
Now the auction status should be set to "Ended" and the winner and winning bid is shown.


## Licensing

This project is based on [hyperledger fabric samples](https://github.com/hyperledger/fabric-samples).
