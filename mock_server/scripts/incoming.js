// Adds or removes the "incoming" products (data/incoming.json) in data/db.json.
// They exist only on the server — never in the app's bundled seed — so you can
// demo new data arriving when the app comes back online.
//
//   npm run incoming:add      # run while the server is STOPPED, then npm start
//   npm run incoming:remove   # back to the seeded catalog
//
// json-server reads db.json once at start, so restart the server after either.
const fs = require('fs');
const path = require('path');

const dbFile = path.join(__dirname, '..', 'data', 'db.json');
const incoming = require('../data/incoming.json');
const ids = new Set(incoming.products.map((p) => p.id));

const mode = process.argv[2];
if (mode !== 'add' && mode !== 'remove') {
  console.error('usage: node scripts/incoming.js add|remove');
  process.exit(1);
}

const db = JSON.parse(fs.readFileSync(dbFile, 'utf8'));

// Always start clean, so running "add" twice doesn't duplicate anything.
db.products = db.products.filter((p) => !ids.has(p.id));
for (const section of db.sections) {
  section.productIds = section.productIds.filter((id) => !ids.has(id));
}

if (mode === 'add') {
  db.products.push(...incoming.products);
  for (const [sectionId, productId] of Object.entries(incoming.placements)) {
    const section = db.sections.find((s) => s.id === sectionId);
    if (!section) throw new Error(`No section "${sectionId}" in db.json`);
    section.productIds.unshift(productId); // first in the row, easy to spot
  }
}

db.meta.updatedAt = new Date().toISOString();
fs.writeFileSync(dbFile, JSON.stringify(db, null, 2) + '\n');

for (const p of incoming.products) {
  console.log(`${mode === 'add' ? '+' : '-'} ${p.name} (${p.id})`);
}
console.log(mode === 'add'
  ? 'Added. Start (or restart) the server: npm start'
  : 'Removed. Restart the server if it is running.');
