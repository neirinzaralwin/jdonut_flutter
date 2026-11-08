// Copies public collections from data/db.json into the Flutter app's bundled seed assets,
// so first launch (offline) shows the same data the server serves.
// Incoming products (data/incoming.json) are left out: they only ever come from the server.
const fs = require('fs');
const path = require('path');

const db = require('../data/db.json');
const incoming = require('../data/incoming.json');
const incomingIds = new Set(incoming.products.map((p) => p.id));

const seedDir = path.join(__dirname, '..', '..', 'app', 'assets', 'seed');
const collections = {
  products: db.products.filter((p) => !incomingIds.has(p.id)),
  banners: db.banners,
  sections: db.sections.map((s) => ({
    ...s,
    productIds: s.productIds.filter((id) => !incomingIds.has(id)),
  })),
  shops: db.shops,
};

fs.mkdirSync(seedDir, { recursive: true });
for (const [name, data] of Object.entries(collections)) {
  const file = path.join(seedDir, `${name}.json`);
  fs.writeFileSync(file, JSON.stringify({ version: 1, updatedAt: db.meta.updatedAt, data }, null, 2));
  console.log(`seed → ${path.relative(process.cwd(), file)} (${data.length})`);
}
