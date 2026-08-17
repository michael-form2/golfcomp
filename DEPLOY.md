# May Open — Deploy to mayopen.golfcomp.com.au

## One-time setup (5 min)

### 1. Install Node + Vercel CLI

If you don't have Node already, install from <https://nodejs.org> (LTS version, tick "Add to PATH").

Then in Cursor's terminal:

```bash
npm install -g vercel
```

### 2. Log in to Vercel

```bash
vercel login
```

Pick "Continue with GitHub" (or Email). It opens a browser to authenticate.

### 3. Link this folder

From the May Open folder in Cursor's terminal:

```bash
cd "C:\Dropbox\May Open"
vercel
```

It'll ask a few questions:

- **Set up and deploy?** → `Y`
- **Which scope?** → your personal account
- **Link to existing project?** → `N`
- **What's your project's name?** → `may-open` (or whatever)
- **In which directory is your code located?** → `./` (just press Enter)
- **Want to modify these settings?** → `N`

It deploys and gives you a preview URL like `may-open-abc123.vercel.app`. Visit that to confirm everything works.

### 4. Promote to production

```bash
vercel --prod
```

Now it's live at `may-open.vercel.app` (or whatever the project name resolved to).

---

## Iterating

After this, the loop is:

1. **Edit** `may-open.html` in Cursor
2. **Test locally** — double-click `start-server.bat`, refresh browser
3. **Deploy** when happy:

```bash
vercel --prod
```

Each `vercel --prod` overwrites production. Takes ~10 seconds.

---

## Connect mayopen.golfcomp.com.au

### A. Add the domain in Vercel

1. Go to <https://vercel.com/dashboard> → click your `may-open` project → **Settings** → **Domains**
2. Type `mayopen.golfcomp.com.au` → **Add**
3. Vercel shows a DNS record to add — typically:
   - **Type:** CNAME
   - **Name:** mayopen
   - **Value:** `cname.vercel-dns.com`

Copy that value exactly as shown.

### B. Add the CNAME at GoDaddy

1. Log in to <https://godaddy.com> → **My Products** → **Domains** → click `golfcomp.com.au` → **DNS**
2. Click **Add New Record**
3. Fill in:
   - **Type:** CNAME
   - **Name:** `mayopen`  *(just the subdomain prefix, not the full domain)*
   - **Value:** `cname.vercel-dns.com`  *(paste whatever Vercel told you)*
   - **TTL:** 1 hour (default is fine)
4. **Save**

### C. Wait

DNS propagation usually takes 1–15 minutes via GoDaddy. SSL is provisioned automatically by Vercel.

Refresh the Domains page in Vercel — the chip next to `mayopen.golfcomp.com.au` will go green when it's working.

Then anyone can hit <https://mayopen.golfcomp.com.au>.

---

## Sharing with the boys

URL: **<https://mayopen.golfcomp.com.au>**
PIN: whatever you set in the Supabase `settings` table (default `1234` — change it)

They open the link on their phone, hit **Day 1** or **Day 2**, enter the PIN once, and start scoring. Leaderboard updates live for everyone.

---

## Useful Vercel CLI commands

```bash
vercel                  # deploy a preview build
vercel --prod           # deploy to production
vercel ls               # list deployments
vercel logs             # tail logs for the latest deployment
vercel domains ls       # check connected domains
vercel env ls           # list environment variables
```

---

## If something breaks

**Vercel build fails:** check the output — for a static site there's almost nothing to fail on. If it complains about `vercel.json`, validate the JSON.

**Domain shows "Invalid configuration":** the CNAME at GoDaddy is wrong or hasn't propagated yet. Try `nslookup mayopen.golfcomp.com.au` from a terminal — it should resolve to `*.vercel-dns.com`.

**App loads but stays on "Connecting…":** the Supabase publishable key or URL is wrong, or the browser is blocking the connection. Open DevTools → Console and look for errors.

**Scores don't sync between phones:** open DevTools → Network → WS tab — there should be a Supabase WebSocket connection. If not, realtime isn't initialised — refresh and check the connection chip.
