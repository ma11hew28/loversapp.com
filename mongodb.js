// Start the MongoDB Interactive Shell.
mongo

// Insert a user into the users collection of the lovers database.
  // (db & collections are automatically created if they don't exist.)
use lovers
var user = {
  _id : ObjectId("4d29e5a8532357460eaf9105"),
  fbId : 514417,
  reqs : {
    recv : [ // ordered by time received
      { rid : 3, uid : 12532 },
      { rid : 1, uid : 6432 },
      // ...
      { rid : 4, uid : 34738473 }
    ],
    sent : [ // ordered by time sent
      { rid : 0, uid : 8345332 },
      { rid : 5, uid : 232123432 },
      // ...
      { rid : 2, uid : 1345 }
    ]
  },
  rels : [ // unordered
    { rid : 3, uid : 57484 },
    { rid : 0, uid : 2349 },
    // ...
    { rid : 2, uid : 96833 }
  ]
}
db.users.save(user);
db.users.find({fbId:514417}); // get user we just added
db.users.find({fbId:514417}, {rels:true}); // just get user's rels

db.users.update( { fbId : 5514417 }, { $addToSet : { rels : { rid : 3, uid : 124322 } } });
db.users.update( { fbId : 5514417 }, { $addToSet : { rels : { rid : 3, uid : 57484 } } });
