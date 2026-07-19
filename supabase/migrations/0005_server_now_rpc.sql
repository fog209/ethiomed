-- Anti-clock-spoof: expose the authoritative Postgres server time so the
-- client can evaluate subscription expiry against server time instead of
-- the (spoofable) device clock.
-- Run manually in the Supabase SQL Editor (service role) once. Safe to re-run
-- (CREATE OR REPLACE).

create or replace function public.server_now()
returns timestamptz
language sql
stable
security definer
set search_path = public
as $$
  select now();
$$;

grant execute on function public.server_now() to anon, authenticated;
