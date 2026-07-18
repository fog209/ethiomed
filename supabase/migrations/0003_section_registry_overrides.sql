-- Phase 8: Per-category section label overrides.
-- Extends the already-run 0002_section_registry. Adds a nullable jsonb column
-- holding a map of category name -> override label, e.g.
--   {"Anatomy": "Contents & Relationships", "Microbiology": "Life Cycle & Virulence"}
-- keyed by the exact category strings in lib/core/config/app_config.dart
-- (preclinicalCategories: 'Anatomy', 'Microbiology', ...).
--
-- CHECKPOINT: do NOT execute against live Supabase without explicit go-ahead.
-- Run manually in the Supabase SQL Editor (service role).

alter table public.section_registry
  add column if not exists category_label_overrides jsonb;

-- Seed the two handover-doc examples (pathophysiology for Anatomy +
-- Microbiology; treatment for Anatomy). Confirm exact override labels with
-- the product owner before relying on a fuller mapping — only these two are
-- specified in the handover.
update public.section_registry
  set category_label_overrides =
        '{"Anatomy": "Contents & Relationships", "Microbiology": "Life Cycle & Virulence"}'
  where key = 'pathophysiology';

update public.section_registry
  set category_label_overrides = '{"Anatomy": "Management"}'
  where key = 'treatment';
