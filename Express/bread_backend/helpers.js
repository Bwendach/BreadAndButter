function handleError(res, error, status = 500) {
  res.status(status).json({ error: error.message || error });
}

module.exports = { handleError };

function generateToken(n) {
  var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  var token = "";
  for (var i = 0; i < n; i++) {
    token += chars[Math.floor(Math.random() * chars.length)];
  }
  return token;
}

module.exports = { generateToken };
