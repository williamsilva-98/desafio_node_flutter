const User = require("./user_model");
const { Op } = require("sequelize");

async function create(name, email) {
  const user = await User.create({ name, email });
  return user.toJSON();
}

async function findAll(filters = {}) {
  const { name, email } = filters;
  const where = {};

  if (name && typeof name === "string" && name.trim()) {
    where.name = { [Op.like]: `%${name.trim()}%` };
  }
  
  if (email && typeof email === "string" && email.trim()) {
    where.email = { [Op.like]: `%${email.trim()}%` };
  }

  const users = await User.findAll({
    where: Object.keys(where).length ? where : undefined,
    order: [["id", "ASC"]],
  });

  return users.map((u) => u.toJSON());
}

module.exports = {
  create,
  findAll,
};
