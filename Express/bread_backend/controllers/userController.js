const {
  generateToken,
} = require("../../../../Code/Express/anime_backend/helper/helper");
const db = require("../database");
const { handleError } = require("../helpers");

exports.login = (req, res) => {
  const { login, password } = req.body;

  db.query(
    "SELECT userId, username, role FROM users WHERE (email = ? OR username = ?) AND password = ?",
    [login, login, password],
    (err, result) => {
      if (err) return handleError(res, err);

      if (result.length > 0) {
        const userId = result[0].userId;
        const newGeneratedToken = generateToken(10);

        db.query(
          "UPDATE users SET token = ? WHERE userId = ?",
          [newGeneratedToken, userId],
          (err2) => {
            if (err2) return handleError(res, err2);
            res.status(200).json({
              token: newGeneratedToken,
              userId: userId,
            });
          }
        );
      } else {
        res.status(401).json({ error: "Invalid credentials" });
      }
    }
  );
};

// Get username by userId
exports.getUsername = (req, res) => {
  const { userId } = req.params;

  db.query(
    "SELECT username FROM users WHERE userId = ?",
    [userId],
    (err, results) => {
      if (err) return handleError(res, err);
      if (results.length === 0)
        return res.status(404).json({ error: "User not found" });
      res.json(results[0]);
    }
  );
};

// Get user details by userId
exports.getUser = (req, res) => {
  const { userId } = req.params;

  db.query(
    "SELECT userId, username, role FROM users WHERE userId = ?",
    [userId],
    (err, results) => {
      if (err) return handleError(res, err);
      if (results.length === 0)
        return res.status(404).json({ error: "User not found" });
      res.json(results[0]);
    }
  );
};
