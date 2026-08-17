# Moving mayopen to the new Vercel account

Goal: get `C:\dev\mayopen` deploying from your **new** Vercel account, while keeping
**`mayopen.golfcomp.com.au`** working — without access to the old Vercel account.

This works because you control the **domain** at GoDaddy. Vercel lets you claim a domain
off another account if you can prove DNS ownership.

---

## Step 0 — Clear the stale project link

The old link is already backed up in `project-json-backup.txt`.

```powershell
cd C:\dev\mayopen
Remove-Item -Recurse -Force .vercel -ErrorAction SilentlyContinue
```

---

## Step 1 — Make sure you're on the NEW account

```powershell
$env:NODE_TLS_REJECT_UNAUTHORIZED="0"
vercel logout
vercel login
```

Log in as the **new** account. Then confirm:

```powershell
vercel whoami
```

Should print the new account's username.

---

## Step 2 — Deploy to a new project

```powershell
vercel
```

Answers:

- **Set up and deploy?** → `Y`
- **Which scope?** → your new account (or its team)
- **Link to existing project?** → **`N`** (there isn't one on this account yet)
- **Project name?** → `mayopen` (or `golfcomp` — your call, the name doesn't affect the domain)
- **In which directory is your code located?** → `./` (press Enter)
- **Modify settings?** → `N`

It deploys and gives you a preview URL like `mayopen-abc123.vercel.app`.

**Test that URL now** — open it, confirm the app loads. Also try `/new` for the new
multi-comp build. If those work, the code is fine and only the domain is left.

Then promote:

```powershell
vercel --prod
```

---

## Step 3 — Claim the custom domain

1. <https://vercel.com/dashboard> → your new project → **Settings** → **Domains**
2. Type `mayopen.golfcomp.com.au` → **Add**
3. Vercel will respond with one of two things:

### Case A — "Domain is already in use by another account"

Vercel shows a **TXT record** to prove you own the domain. It looks like:

```
Type:  TXT
Name:  _vercel
Value: vc-domain-verify=mayopen.golfcomp.com.au,abc123def456...
```

Add that at GoDaddy (see Step 4), wait a few minutes, then click **Verify** in Vercel.
Once verified, Vercel detaches the domain from the old account and attaches it to yours.

### Case B — It just works

Sometimes the old project's domain has already lapsed. Vercel then shows the normal
CNAME instructions — skip to Step 4 and add the CNAME.

---

## Step 4 — DNS at GoDaddy

1. <https://godaddy.com> → **My Products** → **Domains** → `golfcomp.com.au` → **DNS**
2. **Add** whatever record Vercel asked for:

**For ownership verification (Case A):**

| Field | Value |
|---|---|
| Type | TXT |
| Name | `_vercel` |
| Value | *(paste exactly what Vercel showed)* |
| TTL | 1 hour |

**For the actual routing (both cases):**

| Field | Value |
|---|---|
| Type | CNAME |
| Name | `mayopen` |
| Value | `cname.vercel-dns.com` *(or whatever Vercel shows)* |
| TTL | 1 hour |

If a `mayopen` CNAME already exists pointing at Vercel, **edit** it rather than adding a second.

3. Save.

---

## Step 5 — Wait and verify

DNS usually propagates in 1–15 minutes on GoDaddy.

Check from PowerShell:

```powershell
nslookup mayopen.golfcomp.com.au
```

Should resolve to something `*.vercel-dns.com`.

In Vercel → Settings → Domains, the chip next to the domain goes **green** when it's live.
SSL is issued automatically.

Then open <https://mayopen.golfcomp.com.au> — should be your app, served from the new account.

---

## Step 6 — Re-link the folder (housekeeping)

After all that, `.vercel/project.json` will have been regenerated pointing at the new
project. Confirm:

```powershell
Get-Content .vercel\project.json
```

The `orgId` should differ from the one in `project-json-backup.txt`. From then on,
`vercel --prod` just works.

---

## The TLS thing

Your machine has something intercepting HTTPS (corporate proxy or antivirus SSL scanning),
so every `vercel` command needs:

```powershell
$env:NODE_TLS_REJECT_UNAUTHORIZED="0"
```

first in that PowerShell session. That's a workaround, not a fix. Proper fixes:

- Turn off HTTPS/SSL scanning in your antivirus
- Or export your proxy's root CA and set `NODE_EXTRA_CA_CERTS` to its real path
- Or run deploys from a network without interception (phone hotspot works)

Don't leave `NODE_TLS_REJECT_UNAUTHORIZED=0` set permanently.

---

## If it all goes sideways

**Browser deploy, no CLI:**
<https://vercel.com/new> → drag the `C:\dev\mayopen` folder onto the page. Creates the
project and deploys in one go. Then do Steps 3–5 for the domain.

**Local testing needs none of this:**

```
start-server.bat
```

then <http://localhost:8080/golf-comp.html>. Runs against your live Supabase.

---

## Files being deployed

| File | URL | What it is |
|---|---|---|
| `index.html` | `/` | Current May Open app (unchanged) |
| `may-open.html` | `/may-open` | Same file, direct link |
| `golf-comp.html` | `/new` | New multi-comp app — test this |
| `ritchie-cup.html` | `/ritchie` | Standalone Ritchie fork (superseded, kept as fallback) |
| `Trophy.PNG` | — | Header/gate image |
