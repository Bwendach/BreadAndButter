const express = require("express");
const router = express.Router();
const reviewController = require("../controllers/reviewController");

router.get("/menu/:menuId", reviewController.getAllForMenu);
router.get("/menu/:menuId/user/:userId", reviewController.getForMenuUser);
router.post("/create", reviewController.create);
router.put("/update/:reviewId", reviewController.update);
router.delete("/delete/:reviewId", reviewController.delete);

module.exports = router;
