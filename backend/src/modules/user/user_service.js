const userRepository = require('./user_repository');
const AppError = require('../../shared/errors/app_error');

async function createUser(dados) {
  const { name, email } = dados || {};

  if (!name || typeof name !== 'string' || !name.trim()) {
    throw new AppError('Name is required.', 400);
  }

  if (!email || typeof email !== 'string' || !email.trim()) {
    throw new AppError('Email is required.', 400);
  }

  const existentes = await userRepository.findAll({ email: email });

  if (existentes.length > 0) {
    throw new AppError('User already exists with this email.', 409);
  }

  return userRepository.create(name.trim(), email);
}

async function getAllUsers(filters = {}) {
  return userRepository.findAll(filters);
}

module.exports = {
  createUser,
  getAllUsers,
};
