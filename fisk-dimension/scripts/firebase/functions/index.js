exports.health = (_req, res) => {
  res.status(200).json({ status: "ok", service: "fisk-dimension-functions" });
};
