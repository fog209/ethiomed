-- Admin-only RLS for subscriptions: INSERT/UPDATE can only be performed by
-- users whose profiles.is_admin is true. SELECT remains per-user
-- (auth.uid() = user_id), matching the existing policy. Idempotent: uses
-- DROP POLICY IF EXISTS so the file can be re-run safely.
-- Run manually in the Supabase SQL Editor (service role).

-- Admin helper, mirroring the app's profiles.is_admin boolean (NOT the
-- commented student_type variant in schema.sql).
create or replace function public.is_user_admin(uid uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select coalesce(
    (select is_admin from public.profiles where id = uid),
    false
  );
$$;

-- INSERT: admins only.
drop policy if exists "Admins can insert subscriptions" on public.subscriptions;
create policy "Admins can insert subscriptions"
  on public.subscriptions
  for insert
  to authenticated
  with check (public.is_user_admin(auth.uid()));

-- UPDATE: admins only.
drop policy if exists "Admins can update subscriptions" on public.subscriptions;
create policy "Admins can update subscriptions"
  on public.subscriptions
  for update
  to authenticated
  using (public.is_user_admin(auth.uid()))
  with check (public.is_user_admin(auth.uid()));
