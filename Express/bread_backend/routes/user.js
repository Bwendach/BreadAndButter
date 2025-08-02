const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");

router.post("/login", userController.login);
router.get("/username/:userId", userController.getUsername);
router.get("/:userId", userController.getUser);

module.exports = router;
