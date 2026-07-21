-- User reports table for clinical safety: allows users to flag content errors.
-- Authenticated users can INSERT; admins can SELECT and UPDATE.
-- Run manually in the Supabase SQL Editor (service role).

create table if not exists public.user_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  content_type text not null,
  content_id text not null,
  report_text text not null,
  created_at timestamptz default now() not null,
  status text default 'pending' not null
);

-- Enable RLS
alter table public.user_reports enable row level security;

-- Admin helper: checks if user has admin privileges via profiles.is_admin
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

-- Authenticated users can INSERT their own reports
drop policy if exists "Authenticated users can insert user reports" on public.user_reports;
create policy "Authenticated users can insert user reports"
  on public.user_reports
  for insert
  to authenticated
  with check (auth.uid() is not null);

-- Admins can SELECT and UPDATE
drop policy if exists "Admins can select user reports" on public.user_reports;
create policy "Admins can select user reports"
  on public.user_reports
  for select
  to authenticated
  using (public.is_user_admin(auth.uid()));

drop policy if exists "Admins can update user reports" on public.user_reports;
create policy "Admins can update user reports"
  on public.user_reports
  for update
  to authenticated
  using (public.is_user_admin(auth.uid()))
  with check (public.is_user_admin(auth.uid()));