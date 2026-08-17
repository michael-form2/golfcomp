# May Open 2026 — Live Scoring App

## Files

- `may-open.html` — Main app, Supabase-connected, live scoring across phones
- `may-open-local.html` — Fallback, localStorage only (no internet needed)
- `start-server.bat` — Double-click to run local dev server

## Quick local test (Cursor)

1. Double-click `start-server.bat`. It starts http server on `localhost:8080`.
2. In Cursor, open `may-open.html` and edit. The browser will need a manual refresh after saves (or install the "Live Server" extension for auto-reload).
3. To test from another device on the same Wi-Fi, the .bat prints your local IP — visit `http://YOUR_IP:8080/may-open.html` on your phone.

Alternative: install the **Live Server** extension in Cursor, right-click `may-open.html` → "Open with Live Server". Auto-reloads on save.

## Supabase project

- Project: **may-open-2026** (`fmnghbldrepksatggpdj`)
- Region: ap-southeast-2 (Sydney)
- URL: `https://fmnghbldrepksatggpdj.supabase.co`
- Dashboard: <https://supabase.com/dashboard/project/fmnghbldrepksatggpdj>

### Scoring PIN

Default is `1234`. Anyone with the link can view; PIN is needed to enter or edit scores.

**Change the PIN before the day** in the Supabase dashboard:
1. Open dashboard → Table Editor → `settings`
2. Edit the row's `write_pin` value
3. Tell only the markers what it is

## Deploying to golfcomp.com.au

The app is a single static HTML file. Two options:

**A. Upload via FTP / cPanel.** Drop `may-open.html` into the web root. It will be live at e.g. `golfcomp.com.au/may-open.html` or rename to `index.html` for root.

**B. Cloudflare Pages / Netlify (free, fast, HTTPS).** Drag and drop the file at <https://app.netlify.com/drop> or via Cloudflare Pages. Connect your DNS so `golfcomp.com.au` points at it.

Either way the app talks directly to Supabase from the browser — no server logic needed.

## On the day

1. Confirm players and handicaps in **Setup**
2. Confirm Day 1 Ambrose teams and Day 2 pairings
3. Share the URL + PIN with each group's marker
4. Each group enters their own group's scores hole-by-hole
5. Everyone watches **Leaderboard** update in real time

## Scoring rules baked in

- **Day 1 Ambrose:** Team handicap = ¼ of combined GA handicap (rounded). Nett = gross − team handicap. Driver tracker shows each player's drive count (must be ≥ 6 each).
- **Day 2 Best Ball:** Each player on full Daily Handicap (= rounded GA). Stableford points per player per hole using Stroke Index. Better score of the pair counts.
- **Combined:** Day 1 placing → points (10/8/6/4/2/1) + Day 2 best-ball points.

## If the cloud drops out

- The app caches everything locally and shows an **Offline** chip in the header
- You can keep entering scores — they'll resync when connection returns *(note: scores entered while offline must be re-tapped to sync — current build does not have a retry queue yet)*
- Worst case: use `may-open-local.html` as a pure-offline fallback
