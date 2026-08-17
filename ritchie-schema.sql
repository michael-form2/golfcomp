-- ================================================================
-- RITCHIE CUP 2026 — Supabase schema
-- Adds ritchie_* tables to the same Supabase project used by May Open.
-- Does NOT touch May Open tables. Safe to paste in full.
-- Paste into: Supabase Dashboard → SQL Editor → New query → Run
-- ================================================================

-- ---------- PLAYERS ----------
create table if not exists public.ritchie_players (
  id            text primary key,
  name          text not null,
  hcp           int  not null default 36,
  display_order int
);

-- ---------- TEAMS (3 teams of 3) ----------
create table if not exists public.ritchie_teams (
  team_idx    int  primary key,           -- 0, 1, 2
  team_name   text default '',
  player1_id  text references public.ritchie_players(id),
  player2_id  text references public.ritchie_players(id),
  player3_id  text references public.ritchie_players(id)
);

-- ---------- COURSE (Ivanhoe, 18 holes) ----------
create table if not exists public.ritchie_course_holes (
  hole   int primary key,   -- 1..18
  par    int not null,
  si     int not null,
  metres int
);

-- ---------- SCORES (per player, per hole, gross) ----------
create table if not exists public.ritchie_scores (
  player_id  text references public.ritchie_players(id),
  hole       int  not null check (hole between 1 and 18),
  gross      int  not null check (gross between 1 and 30),
  updated_at timestamptz default now(),
  primary key (player_id, hole)
);

-- ---------- ROUND STATE ----------
create table if not exists public.ritchie_round_state (
  id         int primary key default 1,
  started    boolean default false,
  updated_at timestamptz default now()
);

-- ---------- ROUND LOCK (per team) ----------
create table if not exists public.ritchie_round_lock (
  team_idx   int primary key,
  locked     boolean default false,
  updated_at timestamptz default now()
);

-- ---------- SETTINGS (PINs for this comp) ----------
create table if not exists public.ritchie_settings (
  id            int primary key default 1,
  scoring_pin   text not null default 'RITCHIE',
  admin_pin     text not null default 'RITCHIEADMIN'
);

-- ================================================================
-- ROW LEVEL SECURITY — public read, writes gated by RPCs + PIN
-- ================================================================
alter table public.ritchie_players       enable row level security;
alter table public.ritchie_teams         enable row level security;
alter table public.ritchie_course_holes  enable row level security;
alter table public.ritchie_scores        enable row level security;
alter table public.ritchie_round_state   enable row level security;
alter table public.ritchie_round_lock    enable row level security;
alter table public.ritchie_settings      enable row level security;

drop policy if exists "read ritchie_players"      on public.ritchie_players;
drop policy if exists "read ritchie_teams"        on public.ritchie_teams;
drop policy if exists "read ritchie_course_holes" on public.ritchie_course_holes;
drop policy if exists "read ritchie_scores"       on public.ritchie_scores;
drop policy if exists "read ritchie_round_state"  on public.ritchie_round_state;
drop policy if exists "read ritchie_round_lock"   on public.ritchie_round_lock;

create policy "read ritchie_players"      on public.ritchie_players      for select using (true);
create policy "read ritchie_teams"        on public.ritchie_teams        for select using (true);
create policy "read ritchie_course_holes" on public.ritchie_course_holes for select using (true);
create policy "read ritchie_scores"       on public.ritchie_scores       for select using (true);
create policy "read ritchie_round_state"  on public.ritchie_round_state  for select using (true);
create policy "read ritchie_round_lock"   on public.ritchie_round_lock   for select using (true);
-- ritchie_settings intentionally has NO select policy — PINs never leave the DB

-- ================================================================
-- REALTIME — publish scoring-critical tables
-- ================================================================
do $$
begin
  perform 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='ritchie_players';
  if not found then execute 'alter publication supabase_realtime add table public.ritchie_players'; end if;
  perform 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='ritchie_teams';
  if not found then execute 'alter publication supabase_realtime add table public.ritchie_teams'; end if;
  perform 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='ritchie_course_holes';
  if not found then execute 'alter publication supabase_realtime add table public.ritchie_course_holes'; end if;
  perform 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='ritchie_scores';
  if not found then execute 'alter publication supabase_realtime add table public.ritchie_scores'; end if;
  perform 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='ritchie_round_state';
  if not found then execute 'alter publication supabase_realtime add table public.ritchie_round_state'; end if;
  perform 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='ritchie_round_lock';
  if not found then execute 'alter publication supabase_realtime add table public.ritchie_round_lock'; end if;
end $$;

-- ================================================================
-- SEED — Ivanhoe course (18 holes, par 68)
-- ================================================================
insert into public.ritchie_course_holes (hole, par, si, metres) values
  (1, 4, 10, 323), (2, 4, 2, 414),  (3, 4, 8, 293),  (4, 3, 7, 132),
  (5, 4, 15, 300), (6, 5, 11, 476), (7, 3, 4, 167),  (8, 4, 6, 323),
  (9, 4, 12, 282), (10,4, 5, 365),  (11,4, 13, 264), (12,3, 18, 107),
  (13,4, 1, 389),  (14,4, 17, 254), (15,3, 16, 134), (16,4, 3, 346),
  (17,4, 14, 232), (18,3, 9, 125)
on conflict (hole) do update set par=excluded.par, si=excluded.si, metres=excluded.metres;

-- ================================================================
-- SEED — 9 players, all off HC 36 (beginners)
-- ================================================================
insert into public.ritchie_players (id, name, hcp, display_order) values
  ('r01', 'Ritchie', 36, 1),
  ('r02', 'Jake',    36, 2),
  ('r03', 'Eamon',   36, 3),
  ('r04', 'Freddy',  36, 4),
  ('r05', 'Jack',    36, 5),
  ('r06', 'Matteo',  36, 6),
  ('r07', 'Isaac',   36, 7),
  ('r08', 'Marcus',  36, 8),
  ('r09', 'Yash',    36, 9)
on conflict (id) do nothing;

-- ================================================================
-- SEED — 3 empty teams (Ritchie picks on the day)
-- ================================================================
insert into public.ritchie_teams (team_idx, team_name, player1_id, player2_id, player3_id) values
  (0, 'Team 1', null, null, null),
  (1, 'Team 2', null, null, null),
  (2, 'Team 3', null, null, null)
on conflict (team_idx) do nothing;

-- ================================================================
-- SEED — round state + team locks
-- ================================================================
insert into public.ritchie_round_state (id, started) values (1, false)
  on conflict (id) do nothing;

insert into public.ritchie_round_lock (team_idx, locked) values
  (0, false), (1, false), (2, false)
on conflict (team_idx) do nothing;

-- ================================================================
-- SEED — settings (default PINs, change before the day)
-- ================================================================
insert into public.ritchie_settings (id, scoring_pin, admin_pin)
  values (1, 'RITCHIE', 'RITCHIEADMIN')
  on conflict (id) do nothing;

-- ================================================================
-- RPCs — all writes gated by PIN
-- ================================================================

-- PIN verification (own to Ritchie Cup, separate from May Open)
create or replace function public.ritchie_verify_pin(p_pin text)
returns boolean language plpgsql security definer as $$
declare s_pin text; a_pin text;
begin
  select scoring_pin, admin_pin into s_pin, a_pin from public.ritchie_settings where id = 1;
  return p_pin = s_pin or p_pin = a_pin;
end; $$;

create or replace function public.ritchie_verify_admin_pin(p_pin text)
returns boolean language plpgsql security definer as $$
declare a_pin text;
begin
  select admin_pin into a_pin from public.ritchie_settings where id = 1;
  return p_pin = a_pin;
end; $$;

-- Set player
create or replace function public.ritchie_set_player(p_pin text, p_id text, p_name text, p_hcp int)
returns void language plpgsql security definer as $$
begin
  if not public.ritchie_verify_pin(p_pin) then raise exception 'Invalid PIN'; end if;
  update public.ritchie_players set name = p_name, hcp = p_hcp where id = p_id;
end; $$;

-- Set team (3 slots + name)
create or replace function public.ritchie_set_team(
  p_pin text, p_team_idx int, p_p1 text, p_p2 text, p_p3 text, p_name text
) returns void language plpgsql security definer as $$
begin
  if not public.ritchie_verify_pin(p_pin) then raise exception 'Invalid PIN'; end if;
  update public.ritchie_teams
    set player1_id = p_p1, player2_id = p_p2, player3_id = p_p3, team_name = coalesce(p_name, team_name)
    where team_idx = p_team_idx;
end; $$;

-- Set score (upsert; null gross deletes)
create or replace function public.ritchie_set_score(
  p_pin text, p_player_id text, p_hole int, p_gross int
) returns void language plpgsql security definer as $$
begin
  if not public.ritchie_verify_pin(p_pin) then raise exception 'Invalid PIN'; end if;
  if p_gross is null then
    delete from public.ritchie_scores where player_id = p_player_id and hole = p_hole;
  else
    insert into public.ritchie_scores (player_id, hole, gross, updated_at)
      values (p_player_id, p_hole, p_gross, now())
      on conflict (player_id, hole) do update set gross = excluded.gross, updated_at = now();
  end if;
end; $$;

-- Round state (admin only)
create or replace function public.ritchie_set_round_state(p_pin text, p_started boolean)
returns void language plpgsql security definer as $$
begin
  if not public.ritchie_verify_admin_pin(p_pin) then raise exception 'Admin PIN required'; end if;
  update public.ritchie_round_state set started = p_started, updated_at = now() where id = 1;
end; $$;

-- Lock team card (anyone with scoring PIN)
create or replace function public.ritchie_lock_team(p_pin text, p_team_idx int)
returns void language plpgsql security definer as $$
begin
  if not public.ritchie_verify_pin(p_pin) then raise exception 'Invalid PIN'; end if;
  update public.ritchie_round_lock set locked = true, updated_at = now() where team_idx = p_team_idx;
end; $$;

-- Unlock team card (admin only)
create or replace function public.ritchie_unlock_team(p_pin text, p_team_idx int)
returns void language plpgsql security definer as $$
begin
  if not public.ritchie_verify_admin_pin(p_pin) then raise exception 'Admin PIN required'; end if;
  update public.ritchie_round_lock set locked = false, updated_at = now() where team_idx = p_team_idx;
end; $$;

-- Wipe all scores (admin only) — resets for testing
create or replace function public.ritchie_wipe_scores(p_pin text)
returns void language plpgsql security definer as $$
begin
  if not public.ritchie_verify_admin_pin(p_pin) then raise exception 'Admin PIN required'; end if;
  delete from public.ritchie_scores;
  update public.ritchie_round_lock set locked = false, updated_at = now();
end; $$;

-- ================================================================
-- GRANTS — expose RPCs to anon role
-- ================================================================
grant execute on function public.ritchie_verify_pin(text)                      to anon, authenticated;
grant execute on function public.ritchie_verify_admin_pin(text)                to anon, authenticated;
grant execute on function public.ritchie_set_player(text, text, text, int)     to anon, authenticated;
grant execute on function public.ritchie_set_team(text, int, text, text, text, text) to anon, authenticated;
grant execute on function public.ritchie_set_score(text, text, int, int)       to anon, authenticated;
grant execute on function public.ritchie_set_round_state(text, boolean)        to anon, authenticated;
grant execute on function public.ritchie_lock_team(text, int)                  to anon, authenticated;
grant execute on function public.ritchie_unlock_team(text, int)                to anon, authenticated;
grant execute on function public.ritchie_wipe_scores(text)                     to anon, authenticated;

-- ================================================================
-- Done. Sanity checks:
--   select * from public.ritchie_players;         -- 9 rows
--   select * from public.ritchie_course_holes;    -- 18 rows, par 68 total
--   select * from public.ritchie_teams;           -- 3 empty rows
--   select public.ritchie_verify_pin('RITCHIE');  -- true
-- ================================================================
