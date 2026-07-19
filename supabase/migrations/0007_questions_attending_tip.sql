-- Phase 3 F1 follow-up: add an optional "Attending Tip" free-text field to
-- MCQ questions. Mirrors the article dynamic-sections pattern (single optional
-- text column, surfaced after the explanation in-app). Nullable so existing
-- rows are unaffected. Run manually in the Supabase SQL Editor (service role).

alter table public.questions
  add column if not exists attending_tip text;
