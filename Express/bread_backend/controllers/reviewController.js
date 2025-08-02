const db = require("../database");
const { handleError } = require("../helpers");

// Get all reviews for a menu item
exports.getAllForMenu = (req, res) => {
  const { menuId } = req.params;

  db.query(
    "SELECT * FROM menu_reviews WHERE menuId = ? ORDER BY reviewId DESC",
    [menuId],
    (err, results) => {
      if (err) return handleError(res, err);
      res.json(results);
    }
  );
};

// Get review for a specific menu and user
exports.getForMenuUser = (req, res) => {
  const { menuId, userId } = req.params;

  db.query(
    "SELECT * FROM menu_reviews WHERE menuId = ? AND userId = ?",
    [menuId, userId],
    (err, results) => {
      if (err) return handleError(res, err);
      if (results.length === 0)
        return res.status(404).json({ error: "Review not found" });
      res.json(results);
    }
  );
};

// Create review
exports.create = (req, res) => {
  const { menuId, userId, reviewContent, reviewRating } = req.body;

  console.log("Creating review with:", {
    menuId,
    userId,
    reviewContent,
    reviewRating,
  });

  // Validate inputs
  if (!menuId || !userId || !reviewContent || reviewRating === undefined) {
    return res.status(400).json({
      error: "Missing required fields",
      received: { menuId, userId, reviewContent, reviewRating },
    });
  }

  // Check if user already has a review for this menu
  db.query(
    "SELECT * FROM menu_reviews WHERE menuId = ? AND userId = ?",
    [menuId, userId],
    (err, existing) => {
      if (err) return handleError(res, err);

      if (existing.length > 0) {
        return res
          .status(400)
          .json({ error: "You already have a review for this menu item" });
      }

      // Create new review
      db.query(
        "INSERT INTO menu_reviews (menuId, userId, reviewContent, reviewRating) VALUES (?, ?, ?, ?)",
        [menuId, userId, reviewContent, reviewRating],
        (err, result) => {
          if (err) {
            console.error("Database error:", err);
            return handleError(res, err);
          }
          console.log("Review created successfully:", result.insertId);
          res.json({ reviewId: result.insertId });
        }
      );
    }
  );
};

// Update review
exports.update = (req, res) => {
  const { reviewId } = req.params;
  const { reviewContent, reviewRating } = req.body;

  console.log("Updating review:", { reviewId, reviewContent, reviewRating });

  db.query(
    "UPDATE menu_reviews SET reviewContent = ?, reviewRating = ? WHERE reviewId = ?",
    [reviewContent, reviewRating, reviewId],
    (err, result) => {
      if (err) {
        console.error("Database error:", err);
        return handleError(res, err);
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: "Review not found" });
      }
      res.json({ message: "Review updated successfully" });
    }
  );
};

// Delete review
exports.delete = (req, res) => {
  const { reviewId } = req.params;

  console.log("Deleting review:", reviewId);

  db.query(
    "DELETE FROM menu_reviews WHERE reviewId = ?",
    [reviewId],
    (err, result) => {
      if (err) {
        console.error("Database error:", err);
        return handleError(res, err);
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: "Review not found" });
      }
      res.json({ message: "Review deleted successfully" });
    }
  );
};
