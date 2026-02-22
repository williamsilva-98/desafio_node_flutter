const userService = require('./user_service');

async function create(req, res, next) {
  try {
    const { name, email } = req.body;
    const user = await userService.createUser({ name, email });
    return res.status(201).json(user);
  } catch (err) {
    next(err);
  }
}

async function getAll(req, res, next) {
  try {
    const { name, email } = req.query;
    const users = await userService.getAllUsers({ name, email });
    return res.status(200).json(users);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  create,
  getAll,
};
