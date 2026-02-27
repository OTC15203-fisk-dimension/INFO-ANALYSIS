// Firebase Functions v2-style HTTPS function (works well with firebase-functions@4+)
const { onRequest } = require("firebase-functions/v2/https");

exports.health = onRequest((_req, res) => {
  res.status(200).json({
    status: "ok",
    service: "fisk-dimension-functions",
  });
});
