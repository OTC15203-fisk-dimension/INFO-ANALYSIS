const { onRequest } = require("firebase-functions/v2/https");

exports.health = onRequest((req, res) => {
  res.status(200).json({
    status: "ok",
    service: "fisk-dimension-functions",
    method: req.method,
    timestamp: Date.now(),
  });
});
