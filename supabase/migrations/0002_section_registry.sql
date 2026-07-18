-- Phase 2: Section registry (dynamic article content metadata).
-- Additive: creates a new table + seeds the 16 existing section keys.
-- Run manually in the Supabase SQL Editor (service role). Safe to run
-- repeatedly — the seed uses ON CONFLICT DO NOTHING so re-running is a no-op.
-- ALREADY EXECUTED against live Supabase (verified via anon read on 2026-07-18).
-- Do NOT re-run; schema extensions live in 0003_section_registry_overrides.sql.

create table if not exists public.section_registry (
  key           text primary key,
  label         text not null,
  icon_name     text,                       -- Flutter Icons identifier, nullable
  display_order integer not null default 999,
  applies_to    text[],                     -- e.g. {'clinical'}; null = both
  enabled       boolean not null default true
);

alter table public.section_registry enable row level security;

-- Readable by everyone (anon + authenticated). Writes go through the
-- service-role key only — no anon/authenticated insert/update/delete policy.
drop policy if exists "section_registry_read_all" on public.section_registry;
create policy "section_registry_read_all"
  on public.section_registry
  for select
  using (true);

-- ─────────────────────────────────────────────────────────────
-- SEED: 16 existing keys, display order + icons mirror the current
-- `_clinicalSections` map in lib/features/articles/presentation/
-- article_detail_screen.dart (no visual regression for existing content).
-- `applies_to` is null (both clinical & preclinical) for all — this app's
-- content is clinical; set {'clinical'}/{'preclinical'} only when a
-- preclinical split is introduced.
-- ─────────────────────────────────────────────────────────────
insert into public.section_registry (key, label, icon_name, display_order, applies_to, enabled) values
  ('definition',        '📝 Definition',              'info_outline',                 1,  null, true),
  ('epidemiology',      '🌍 Epidemiology',            'public',                       2,  null, true),
  ('etiology',          '🧬 Etiology',                'biotech',                      3,  null, true),
  ('pathophysiology',   '🔬 Pathophysiology',         'psychology_outlined',          4,  null, true),
  ('clinicalFeatures',  '🩺 Clinical Features',       'list_alt',                     5,  null, true),
  ('redFlags',          '🚩 Red Flags',               'warning_rounded',              6,  null, true),
  ('approach',          '🧭 Approach',                'format_list_numbered',         7,  null, true),
  ('diagnosis',         '🔎 Diagnosis',               'search',                       8,  null, true),
  ('treatment',         '💊 Treatment',               'medication',                   9,  null, true),
  ('contraindications', '🛑 Contraindications',       'report_problem_outlined',      10, null, true),
  ('dontMiss',          '🚨 Don''t Miss',        'priority_high',                 11, null, true),
  ('complications',     '⚠️ Complications',      'warning_amber_rounded',        12, null, true),
  ('clinicalPearls',    '💡 Clinical Pearls',         'lightbulb_outline',            13, null, true),
  ('ethiopianContext',  '🇪🇹 Ethiopian Clinical Pearl', 'local_hospital_outlined',    14, null, true),
  ('mnemonics',         '🧠 Mnemonics',               'auto_awesome_mosaic_outlined', 15, null, true),
  ('examTraps',         '📋 Exam Traps',              'help_outline',                 16, null, true)
on conflict (key) do nothing;
