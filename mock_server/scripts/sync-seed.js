// Copies public collections from data/db.json into the Flutter app's bundled seed assets,
// so first launch (offline) shows the same data the server serves.
const fs = require('fs');
const path = require('path');

const db = require('../data/db.json');
const seedDir = path.join(__dirname, '..', '..', 'app', 'assets', 'seed');
const collections = ['products', 'banners', 'sections', 'shops'];

fs.mkdirSync(seedDir, { recursive: true });
for (const name of collections) {
  const file = path.join(seedDir, `${name}.json`);
  fs.writeFileSync(file, JSON.stringify({ version: 1, updatedAt: db.meta.updatedAt, data: db[name] }, null, 2));
  console.log(`seed → ${path.relative(process.cwd(), file)} (${db[name].length})`);
}
