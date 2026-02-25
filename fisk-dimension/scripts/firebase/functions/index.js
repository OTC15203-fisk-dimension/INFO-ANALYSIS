const functions = require("firebase-functions");

exports.health = functions.https.onRequest((_req, res) => {
  res.status(200).json({
    status: "ok",
    service: "fisk-dimension-functions"
  });
});
