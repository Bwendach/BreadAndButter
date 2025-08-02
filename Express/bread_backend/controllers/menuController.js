const db = require("../database");
const { handleError } = require("../helpers");

// Get all menu
exports.getAll = (req, res) => {
  db.query("SELECT * FROM menu", (err, results) => {
    if (err) return handleError(res, err);
    res.json(results);
  });
};

// Get menu details
exports.getDetails = (req, res) => {
  const { menuId } = req.params;

  db.query("SELECT * FROM menu WHERE menuId = ?", [menuId], (err, results) => {
    if (err) return handleError(res, err);
    if (results.length === 0)
      return res.status(404).json({ error: "Menu not found" });
    res.json(results[0]);
  });

};

// Create menu (admin only)
exports.create = (req, res) => {
  const { menuName, menuDescription, menuPrice } = req.body;
  const menuImageUrl = req.file ? req.file.filename : null;

  if (!req.user || req.user.role !== "admin")
    return res.status(403).json({ error: "Forbidden" });

  db.query(
    "INSERT INTO menu (menuName, menuDescription, menuImageUrl, menuPrice) VALUES (?, ?, ?, ?)",
    [menuName, menuDescription, menuImageUrl, menuPrice],
    (err, result) => {
      if (err) return handleError(res, err);
      res.json({ menuId: result.insertId });
    }
  );

};

// update menu (admin only)
exports.update = (req, res) => {
  const { menuId } = req.params;
  const { menuName, menuDescription, menuPrice } = req.body;

  const menuImageUrl = req.file ? req.file.filename : null;

  if (!req.user || req.user.role !== "admin") {
    return res.status(403).json({ error: "Forbidden" });
  }

  let sql = "UPDATE menu SET menuName = ?, menuDescription = ?, menuPrice = ?";
  const params = [menuName, menuDescription, menuPrice];

  if (menuImageUrl) {
    sql += ", menuImageUrl = ?";
    params.push(menuImageUrl);
  }

  sql += " WHERE menuId = ?";
  params.push(menuId);

  db.query(sql, params, (err) => {
    if (err) {
      return handleError(res, err);
    }
    res.json({ message: "Menu updated successfully" });
  });
};

// Delete menu (admin only)
exports.delete = (req, res) => {
  const { menuId } = req.params;

  if (!req.user || req.user.role !== "admin")
    return res.status(403).json({ error: "Forbidden" });

  db.query("DELETE FROM menu WHERE menuId = ?", [menuId], (err) => {
    if (err) return handleError(res, err);
    res.json({ message: "Menu deleted successfully" });
  });
}