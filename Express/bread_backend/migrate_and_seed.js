const fs = require("fs");
const path = require("path");
const db = require("./database");

function runSqlFile(filePath) {
  return new Promise((resolve, reject) => {
    const sql = fs.readFileSync(filePath, "utf8");
    db.query(sql, (err, results) => {
      if (err) return reject(err);
      resolve(results);
    });
  });
}

async function migrateAndSeed() {
  try {
    console.log("Running migrations...");
    await runSqlFile(
      path.join(__dirname, "migrations", "001_create_tables.sql")
    );
    console.log("Migrations complete.");
    console.log("Running seeders...");
    await runSqlFile(path.join(__dirname, "seeders", "001_seed_data.sql"));
    console.log("Seeding complete.");
    process.exit(0);
  } catch (err) {
    console.error("Migration/Seeding error:", err);
    process.exit(1);
  }
}

migrateAndSeed();
