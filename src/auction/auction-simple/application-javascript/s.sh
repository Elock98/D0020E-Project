node enrollAdmin.js org1
node enrollAdmin.js org2
node enrollAdmin.js org3
node enrollAdmin.js org4

node registerEnrollUser.js org2 seller

node registerEnrollUser.js org1 bidder1
node registerEnrollUser.js org4 bidder4
node registerEnrollUser.js org3 bidder3

node createAuction.js org2 seller PaintingAuction painting

node bid.js org1 bidder1 PaintingAuction 800

node bid.js org4 bidder4 PaintingAuction 500

node bid.js org3 bidder3 PaintingAuction 900