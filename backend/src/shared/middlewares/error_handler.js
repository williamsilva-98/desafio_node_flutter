const AppError = require("../errors/app_error.js");

module.exports = (err, req, res, next) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      status: "error",
      message: err.message,
    });
  }

  console.log(err)

  return res.status(500).json({
    status: "error",
    message: "Internal server error"
  })
};
