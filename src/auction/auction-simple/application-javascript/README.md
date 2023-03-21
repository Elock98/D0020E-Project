# Script to generate JavaScript files for the auction
This readme explains what generatecode.sh does and how it works and what the specific JavaScript files does as well.
## How the script works
The script takes input of how many organizations that is wanted, then it copies files from the templates folder, reads the files and updates them to work with the number of organizations that was put in.

## Intended use of the script
The script is meant to be used with the network scripts to start the auction with a specified number of organizations, but it can also be used separately to generate JavaScript files.

## How to use the script
The script is called by the setup.sh-script
( https://github.com/Elock98/D0020E-Project/blob/8880a839caabb927a23925d029cad185164edd9a/src/network/setup.sh#L201 )
when starting an auction. To use the script separately it is started by:
```
./generatecode.sh <number>
```
where **number** is replaced with how many organizations that is desired.

## Limitations of the script

Due to some bad practice where the script creates multiple duplicate functions in the JavaScript files this script needs to be modified if the intent is to have many organizations.

 ## JavaScript files
Below is a short description of what each of the JavaScript files that is modified by the script does.
 ### AppUtil.js
This file contains a function that creates the chaincode path that all the other files imports.
 ### bid.js
This file is used to generate a bid and the bid's hash-value will be printed to the terminal. Before a bid is generated it checks to see if the bid is valid. If a bid already has been submitted by the organization then the bid's Valid status will be set to False.
 ### closeAuction.js
This file is used to close an auction. Originally used by the seller but currently this is automatically used when all participating organizations has submitted a bid.
 ### createAuction.js
This file creates a new auction.
 ### endAuction.js
This file is used end an auction.
 ### enrollAdmin.js
This file is used to enroll admins, at least one for each organization is needed.
 ### queryAuction.js
This is used to query an auction and it will display information about the auction in the terminal.
 ### queryBid.js
This is used to query a bid and it will display information about the bid in the terminal.
 ### registerEnrollUser.js
This file is used to register and enroll users, for example the seller and bidders. Before this can be used the enrollAdmin.js for this organization has to be used.
 ### revealBid.js
This is used to reveal submitted bids. An auction can not end without at least one revealed bid.
 ### submitBid.js
This file is used to submit bids to an auction. Before a bid is submitted a check is made to see if the bid is Valid or not. If it's not valid it will not be submitted.

