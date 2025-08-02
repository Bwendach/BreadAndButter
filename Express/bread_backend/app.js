var express = require("express");
var path = require("path");
var cookieParser = require("cookie-parser");
var logger = require("morgan");

var indexRouter = require("./routes/index");
var userRouter = require("./routes/user");
var menuRouter = require("./routes/menu");
var reviewRouter = require("./routes/review");

var app = express();

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

app.use("/api/users", userRouter);
app.use("/api/menu", menuRouter);
app.use("/api/reviews", reviewRouter);
app.use("/assets", express.static(path.join(__dirname, "assets")));
app.use("/assets", express.static("assets"));

module.exports = app;
