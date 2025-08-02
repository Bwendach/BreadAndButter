const express = require("express");
const router = express.Router();
const menuController = require("../controllers/menuController");
const multer = require("multer");

var storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "./assets");
  },
  filename: (req, file, cb) => {
    cb(null, file.originalname);
  },
});
const upload = multer({ storage });

function adminOnly(req, res, next) {
  req.user = { role: "admin" };
  next();
}

router.get("/", menuController.getAll);
router.get("/:menuId", menuController.getDetails);
router.post(
  "/create",
  adminOnly,
  upload.single("menuImage"),
  menuController.create
);
router.put(
  "/update/:menuId",
  adminOnly,
  upload.single("menuImage"),
  menuController.update
);
router.delete("/delete/:menuId", adminOnly, menuController.delete);

module.exports = router;
