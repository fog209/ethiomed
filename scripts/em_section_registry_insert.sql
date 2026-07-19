-- Batch 5 / Task 1c: Add Emergency Medicine section keys to the section_registry.
--
-- CONTEXT (verification result): The article detail renderer
-- (lib/features/articles/presentation/article_detail_screen.dart) is FULLY
-- GENERIC. It iterates every key present in an article's `content.sections[]`
-- and sorts by `section_registry.display_order` (falling back to array order
-- for new keys). There is NO hardcoded key allowlist that would silently drop
-- unrecognized keys — an unrecognized key still renders (humanized label +
-- default icon). Therefore NO app-code change is required for these new keys
-- to render; they only need registry rows so they get a real label/icon/order.
--
-- This script is the SQL equivalent. It INSERTs the 3 new EM-specific keys so
-- they render in the requested chronological sequence:
--   1. initialEvaluation       (assess first)
--   2. severityAssessment       (grade the presentation)
--   3. acuteManagementChecklist (act)
--
-- It mirrors the style of supabase/migrations/0002_section_registry.sql and is
-- idempotent (ON CONFLICT (key) DO NOTHING) so re-running is a no-op.
--
-- SCOPING: `applies_to` is set to null (both clinical & preclinical), matching
-- the existing 16 seed rows. The renderer does not filter by `applies_to` — an
-- EM article simply includes these keys in its own `content.sections`, so the
-- rows are harmless to other categories and only surface where the article
-- content actually contains them.
--
-- display_order 17/18/19 keeps them sequential after the existing 16 keys and
-- in the intended chronological order within an EM article.
--
-- DO NOT RUN against live Supabase as part of Batch 5. This is a draft for the
-- owner to apply (service role) when EM content with these keys goes live.
-- Running it is a schema/data write, out of scope for this batch.

insert into public.section_registry (
  key,
  label,
  icon_name,
  display_order,
  applies_to,
  enabled,
  category_label_overrides
) values
  (
    'initialEvaluation',
    '🚑 Initial Evaluation',
    'local_hospital_outlined',
    17,
    null,
    true,
    null
  ),
  (
    'severityAssessment',
    '📊 Severity Assessment',
    'priority_high',
    18,
    null,
    true,
    null
  ),
  (
    'acuteManagementChecklist',
    '✅ Acute Management Checklist',
    'format_list_numbered',
    19,
    null,
    true,
    null
  )
on conflict (key) do nothing;
