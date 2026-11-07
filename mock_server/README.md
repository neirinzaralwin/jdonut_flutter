# mock_server

json-server mock of the J'Donuts public API. Contract: `../docs/mock-server.md`.

```bash
npm install
npm start          # http://localhost:3000/v1/products
npm run dev        # + 800 ms latency (see skeletons)
npm run flaky      # 30% 503s (see retry/error states)
npm run sync-seed  # db.json → ../app/assets/seed/
```
Drop images into `public/images/{products,banners,shops}/<id>.png` and the same files into `../app/assets/images/...`.
