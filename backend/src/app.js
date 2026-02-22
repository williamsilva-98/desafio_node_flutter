const express = require('express');
const userRoutes = require('./modules/user/user_routes');
const errorHandler = require('./shared/middlewares/error_handler');

const app = express();

app.use(express.json());
app.use("/users", userRoutes);
app.use(errorHandler);

module.exports = app;
