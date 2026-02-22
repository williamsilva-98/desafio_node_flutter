// Represents all the errors that the user can cause.
// Not errors of bugs, crashes, etc..
class AppError extends Error {
  constructor(message, statusCode = 400) {
    super(message);

    this.statusCode = statusCode;
    this.isOperational = true;
  }
}

module.exports = AppError;
