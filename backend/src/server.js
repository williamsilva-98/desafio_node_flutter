require('dotenv').config();
const app = require("./app");
const sequelize = require("./infra/database/sequelize");

const PORT = process.env.PORT;

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);

async function start() {
  try {
    await sequelize.authenticate();
    await sequelize.sync();
    
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  } catch (error) {
    console.log(`❌ Startup error: ${error}`);
    process.exit(1);
  }
}

async function shutdown(signal) {
  console.log(`Received ${signal}. Gracefully shutting down...`);
  await sequelize.close();
  process.exit(0);
}

start();
