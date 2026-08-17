# Ritchie Cup 2026 — Setup & Deploy

Everything you need to get the Ritchie Cup live at **`mayopen.golfcomp.com.au/ritchie`** by Saturday 8 Aug 2026.

Total time: ~10 minutes.

---

## Step 1 — Apply the Supabase schema (2 min)

Adds `ritchie_*` tables to the existing May Open Supabase project. Does NOT touch May Open tables.

1. Go to <https://supabase.com/dashboard/project/fmnghbldrepksatggpdj/sql>
2. Click **New query**
3. Open `ritchie-schema.sql` in this folder, copy the entire file
4. Paste into the SQL editor, click **Run**
5. You should see "Success. No rows returned."

**Sanity check** — in a new SQL query, run:

```sql
select count(*) from ritchie_players;         -- should be 9
select count(*) from ritchie_course_holes;    -- should be 18
select sum(par) from ritchie_course_holes;    -- should be 68
select public.ritchie_verify_pin('RITCHIE');  -- should be true
```

## Step 2 — Change the PINs (1 min)

Default PINs are placeholders. Change them:

```sql
update public.ritchie_settings
  set scoring_pin = 'YOUR_SCORING_PIN',
      admin_pin   = 'YOUR_ADMIN_PIN'
  where id = 1;
```

Suggested: something short + memorable for scoring (kids will type it), and something longer for admin.

## Step 3 — Test locally (2 min)

1. Double-click `start-server.bat`
2. Open `http://localhost:8080/ritchie-cup.html`
3. You should see the Ritchie Cup landing (birthday cake icon, "Tap your team to begin")
4. Click **Admin login** → enter your admin PIN → should get "Admin mode unlocked"
5. Go to **Setup** — you should see 9 players (Ritchie, Jake, Eamon, Freddy, Jack, Matteo, Isaac, Marcus, Yash) all off HC 36
6. Assign a couple of players to Team 1 to test — refresh the page, they should still be there (proof Supabase saved)

## Step 4 — Deploy to Vercel (30 sec)

From this folder in Cursor's terminal:

```bash
vercel --prod
```

Vercel deploys both files. Wait ~10 seconds, then hit:

- **May Open:** <https://mayopen.golfcomp.com.au> (unchanged)
- **Ritchie Cup:** <https://mayopen.golfcomp.com.au/ritchie>

The `/ritchie` route is a rewrite in `vercel.json` that points to `ritchie-cup.html`.

## Step 5 — Ritchie picks teams (day before or on the day)

1. Send Ritchie the link + the admin PIN (only Ritchie gets admin)
2. He opens `mayopen.golfcomp.com.au/ritchie` → Admin login → Setup → assigns players to Team 1, 2, 3
3. Team names default to "Team 1/2/3" but Ritchie can rename them (e.g. "Boys Club", "The Champions", "Ritchie's Ringers")

**Or** Ritchie picks in person on the morning of and you enter it via Setup on your phone. Same thing.

## Step 6 — On the day (Saturday 8 Aug)

**Before the round:**
1. Open the app on your phone. Enter Admin PIN.
2. Go to **Setup** → confirm all teams filled correctly
3. Tap **Start round** at the bottom of Setup (the "Round Control" card)

**During the round:**
- One phone per group. Each group has a "scorer" who taps in scores hole-by-hole.
- Kids see their points update live. Scorer PIN gets them into scoring; admin PIN is only needed for Round Control, Danger Zone, and unlocking submitted cards.
- **Score entry per hole:** Score tab → pick your team from dropdown → use +/− or type each player's gross → app shows Stableford points, highlights the best score, and adds it to that player's tally.
- **Live leaderboard:** anyone on any device can watch — just open the URL, no PIN needed for view-only if you skip the gate (or use `?watch=1` at the end of the URL).

**End of round:**
- Each team's scorer taps **Submit card & lock** (bottom of Score tab)
- Leaderboard shows team ladder + individual ladder + champion banner (fires when all 3 teams complete)
- Red flag next to any team with a player under 4 contributions

## The format at a glance

**3-Man Stableford** (all players off HC 36 = 2 strokes/hole):
- Every kid scores their own hole
- Team score per hole = **best** Stableford of the 3
- That best score is credited to the kid who scored it (their "individual points" tally)
- If 2 or 3 tie on the max, they all get credit (fair, and helps everyone hit min-4)
- Each player must contribute to ≥ 4 holes across the round — soft warning if not, no DQ

**Points on par 4 (all with 2 strokes):**
- Gross 4 (nett 2 = eagle) → 4 pts
- Gross 5 (nett 3 = birdie) → 3 pts
- Gross 6 (nett 4 = par) → 2 pts
- Gross 7 (nett 5 = bogey) → 1 pt
- Gross 8+ → 0 pts

Beginners on par 4s should aim for gross 6 (2 pts) — perfectly achievable.

## If something breaks

- **App loads but says "Connecting…"** — Supabase URL or key wrong. Check `ritchie-cup.html` line ~168 (SUPA_URL / SUPA_KEY) vs your Supabase project. Should match May Open's values since it's the same project.
- **"Invalid PIN"** — you're using the wrong PIN. Confirm what you set in Step 2 by running: `select * from public.ritchie_settings;`
- **Scores don't sync** — realtime not enabled. Rerun the "REALTIME" block in `ritchie-schema.sql`.
- **/ritchie 404s** — Vercel didn't pick up the rewrite. Run `vercel --prod` again. Or hit `/ritchie-cup.html` directly.

## Files in this folder

- `ritchie-schema.sql` — Supabase migration (Step 1)
- `ritchie-cup.html` — the app itself
- `vercel.json` — updated with `/ritchie` rewrite
- `may-open.html` / `index.html` — May Open app (unchanged)
- `RITCHIE-SETUP.md` — this file

---

## Post-comp (after 8 Aug)

Once the Ritchie Cup is done, we can:
- Save the results as an archive entry (like May Open 2026)
- Refactor may-open + ritchie-cup into a proper multi-comp platform with a "Create Comp" wizard (both apps become data-driven from the same codebase)

That's the plan post-birthday. This week is about shipping Ritchie safely.
