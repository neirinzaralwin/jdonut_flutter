# 03 — Task 2: Home and Product detail with offline data

After Welcome, **Let's explore** opens Home.

## Data
- Build all data locally: products, banners, sections, shops, member profile. **Seed from bundled JSON into the local DB on first launch.**
- Optional: serve public data (products, banners, shops) from own mock server, **versioned `/v1/...`** with a `{data, error, meta}` envelope. Local DB is then the cache and **single source of truth** for UI.
- After first launch the app must work fully in **airplane mode**: Home, Product detail and Rewards render, **images included**.
- When network returns: refresh in background **and** on pull-to-refresh. Show a small **offline banner** while offline.
- Cache images on disk with placeholder and error state. Bundle seed images as assets so first launch without network still shows them.
- **One member record for every screen.** Mock-ups disagree (Home: Bronze, 1,290 pts to Gold; Rewards: Silver, 500) — both screens must read the same local data.

## Home (screen 8)
- Header: member name + photo, tier, points to next tier, notification bell with count.
- Banner carousel, then horizontal lists: Seasonal specials, Popular, Order again — discount badges from data.
- Nearby shops: "There are 4 J'Donut shops near you" + shop cards. Display only (Explore now / Order online: no action).
- Loading = **skeletons, not spinners**. Each section has its own empty and error state.

## Product detail (screen 9)
- Every product tile opens Product detail for that product. Coconut Donut = reference design.
- Shows product code, name, price in MMK with thousands separators (`3,200 MMK`), New badge from data, image, description under "What's this?".
- Quantity stepper: min 1; Add to cart shows live total (quantity × price).
- Add to cart needs visual feedback only; persistent cart = bonus.

## Example product record
```json
{"id": "p_coconut", "code": "JD022123", "name": "Coconut Donut", "priceMmk": 3200,
 "isNew": true, "discountPercent": null, "imageUrl": "https://…",
 "description": "Enjoy our scrumptious donuts …"}
```
