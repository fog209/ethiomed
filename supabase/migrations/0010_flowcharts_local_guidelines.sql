-- Draft migration: Flowcharts + Local Guidelines (read-only reference content).
--
-- Migration number 0010 (reserved). Do NOT run by hand against production
-- without the owner's sign-off — this file is drafted only; the applying
-- step is a manual SQL Editor paste by the owner.
--
-- RLS model for BOTH tables: authenticated users MAY SELECT; NO client-side
-- write access (content is admin-managed, e.g. via the Supabase dashboard or
-- a service-role script). No INSERT/UPDATE/DELETE policies are created for the
-- authenticated role, so the only writers would be a SECURITY DEFINER RPC or a
-- direct dashboard edit by an admin.
--
-- Storage buckets are NOT SQL objects. They MUST be created separately in the
-- Supabase dashboard (Storage -> New bucket):
--   * flowchart-images    (public: yes  — images are referenced by URL in app)
--   * local-guidelines-docs (public: no — PDFs/docs should be access-controlled;
--                            if made public, adjust the file_url references)
-- After creating the bucket, upload objects and copy their public/ signed URL
-- into the image_url / file_url columns below.

-- ─────────────────────────────────────────────────────────────────────────
-- 1) flowcharts table
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.flowcharts (
  id         uuid primary key default uuid_generate_v4(),
  title      text not null,
  specialty  text,                       -- specialty / concept tag
  image_url  text not null,              -- URL of the flowchart image
  created_at timestamptz not null default now()
);

create index if not exists flowcharts_created_at_idx
  on public.flowcharts (created_at desc);
create index if not exists flowcharts_specialty_idx
  on public.flowcharts (specialty);

alter table public.flowcharts enable row level security;

drop policy if exists "Authenticated users can read flowcharts"
  on public.flowcharts;
create policy "Authenticated users can read flowcharts"
  on public.flowcharts
  for select
  to authenticated
  using (true);

-- ─────────────────────────────────────────────────────────────────────────
-- 2) local_guidelines table
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists public.local_guidelines (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  description text,
  file_url    text not null,             -- URL of the guideline document
  file_type   text,                      -- e.g. 'pdf', 'docx'
  specialty   text,                      -- specialty tag
  uploaded_at timestamptz not null default now()
);

create index if not exists local_guidelines_uploaded_at_idx
  on public.local_guidelines (uploaded_at desc);
create index if not exists local_guidelines_specialty_idx
  on public.local_guidelines (specialty);

alter table public.local_guidelines enable row level security;

drop policy if exists "Authenticated users can read local_guidelines"
  on public.local_guidelines;
create policy "Authenticated users can read local_guidelines"
  on public.local_guidelines
  for select
  to authenticated
  using (true);
