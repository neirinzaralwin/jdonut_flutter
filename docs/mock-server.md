# Mock server (json-server)

Location: `mock_server/`. Optional per brief, used to demo background refresh.

## Run
```bash
cd mock_server
npm install
npm start            # http://localhost:3000
npm run sync-seed    # copy db.json → app/assets/seed/*.json
```
Android emulator base URL: `http://10.0.2.2:3000`. iOS simulator: `http://localhost:3000`.

## Contract
All responses are wrapped:
```json
{ "data": <payload|null>, "error": null | {"code": "NOT_FOUND", "message": "..."}, "meta": {"version": 1, "updatedAt": "ISO", "count": 4} }
```
| Method | Path | Data |
|---|---|---|
| GET | /v1/health | `{ "status": "ok" }` (reachability check) |
| GET | /v1/products | Product[] |
| GET | /v1/products/:id | Product |
| GET | /v1/banners | Banner[] |
| GET | /v1/sections | Section[] (`seasonal`, `popular`, `order_again` → productIds) |
| GET | /v1/shops | Shop[] |
| GET | /static/images/... | image files |

Member profile, challenges and users are **not** served (local-only per brief).

## Dev toggles (env vars)
- `LATENCY_MS=800` — add delay to see skeletons.
- `FAIL_RATE=0.3` — random 503s to exercise retry + error states.
