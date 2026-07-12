-- Account-sharing prevention: cap concurrent active sessions per account.
-- Applied via the Supabase SQL editor / migration tooling (not run by the
-- Flutter build). The Dart client in lib/features/auth/data/auth_service.dart
-- inserts/updates/prunes rows here, capped at 2 per user.

create table if not exists public.active_sessions (
  user_id      uuid        not null references auth.users (id) on delete cascade,
  device_id    text        not null,
  created_at    timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  primary key (user_id, device_id)
);

alter table public.active_sessions enable row level security;

-- Users see only their own session rows.
create policy "select own sessions"
  on public.active_sessions
  for select
  using (auth.uid() = user_id);

-- Users may only insert (upsert) rows for themselves.
create policy "insert own sessions"
  on public.active_sessions
  for insert
  with check (auth.uid() = user_id);

-- Users may only update their own rows (last_seen_at heartbeat).
create policy "update own sessions"
  on public.active_sessions
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Users may only delete their own rows (prune).
create policy "delete own sessions"
  on public.active_sessions
  for delete
  using (auth.uid() = user_id);
