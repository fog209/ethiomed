

```sql
-- WardReady — Supabase Schema Snapshot
-- Last updated: 2026-06-19
-- Update this file whenever you run DDL in the Supabase SQL Editor.
-- KiloCode reads this to understand the DB without you explaining it.

-- ─────────────────────────────────────────────────────────────
-- EXTENSIONS
-- ─────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────────────────────────
-- PROFILES
-- ─────────────────────────────────────────────────────────────

CREATE TABLE profiles (
  id           uuid REFERENCES auth.users PRIMARY KEY,
  full_name    text,
  student_type text,
  created_at   timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- ─────────────────────────────────────────────────────────────
-- SUBSCRIPTIONS
-- ─────────────────────────────────────────────────────────────

CREATE TABLE subscriptions (
  id           uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id      uuid REFERENCES auth.users NOT NULL,
  status       text NOT NULL DEFAULT 'pending', -- pending | active | expired
  expiry_date  timestamptz,
  activated_at timestamptz
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see own subscription"
  ON subscriptions FOR SELECT USING (auth.uid() = user_id);

-- Admin policies — run Task 1 (Phase 3) to add these:
-- CREATE POLICY "Admins can view all subscriptions"
--   ON subscriptions FOR SELECT
--   USING (auth.uid() = user_id OR public.is_user_admin(auth.uid()));
-- CREATE POLICY "Admins can update all subscriptions"
--   ON subscriptions FOR UPDATE
--   USING (public.is_user_admin(auth.uid()))
--   WITH CHECK (public.is_user_admin(auth.uid()));

-- ─────────────────────────────────────────────────────────────
-- ARTICLES
-- ─────────────────────────────────────────────────────────────

CREATE TABLE articles (
  id          uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  title       text NOT NULL,
  category    text,
  content     jsonb,
  image_url   text,
  video_url   text,
  subcategory text,   -- exists, all NULL, not used yet
  slug        text UNIQUE, -- exists, all NULL, not used yet
  updated_at  timestamptz DEFAULT now()
);

ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read articles"
  ON articles FOR SELECT USING (true);

CREATE INDEX idx_articles_updated_at ON articles(updated_at);

-- APPROVED CATEGORY STRINGS (never retype — copy paste only):
-- "Internal Medicine"   ← Cardiology + Neurology + Nephrology merged
-- "Pulmonology"
-- "Infectious Diseases"
-- "Gastroenterology"
-- "Endocrinology"
-- "Hematology"
-- "OB/GYN"
-- "Pediatrics"
-- "General Surgery"
-- "Psychiatry"
-- "Dermatology"
-- "Ophthalmology"
-- "ENT"
-- "Pharmacology"
-- "Microbiology"
-- "Physiology"
-- "Biochemistry"
-- "Pathology"
-- "Anatomy"

-- RETIRED — do not use:
-- "Cardiology" | "Neurology" | "Nephrology"

-- CLINICAL CONTENT SCHEMA (10 fields in jsonb):
-- definition, epidemiology, etiology, pathophysiology,
-- clinicalFeatures, diagnosis, treatment, complications,
-- ethiopianContext, mnemonics

-- ─────────────────────────────────────────────────────────────
-- QUESTIONS (Phase 3 — F1 MCQ Practice Mode)
-- ─────────────────────────────────────────────────────────────

CREATE TABLE questions (
  id             uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  article_id     uuid REFERENCES articles(id) ON DELETE CASCADE,
  stem           text NOT NULL,
  option_a       text NOT NULL,
  option_b       text NOT NULL,
  option_c       text NOT NULL,
  option_d       text NOT NULL,
  correct_option char(1) NOT NULL,  -- 'a' | 'b' | 'c' | 'd' lowercase
  explanation    text NOT NULL,
  category       text,
  difficulty     text DEFAULT 'medium', -- easy | medium | hard
  tested_field   text DEFAULT 'clinicalFeatures', -- for Learning Radar (35D)
  updated_at     timestamptz DEFAULT now()
);

ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read questions"
  ON questions FOR SELECT USING (true);

CREATE INDEX idx_questions_category ON questions(category);
CREATE INDEX idx_questions_article  ON questions(article_id);

-- ─────────────────────────────────────────────────────────────
-- CASES (deferred to v1.1)
-- ─────────────────────────────────────────────────────────────

-- CREATE TABLE cases (
--   id                   uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
--   category             text NOT NULL,
--   vignette             text NOT NULL,
--   question             text NOT NULL,
--   option_a             text NOT NULL,
--   option_b             text NOT NULL,
--   option_c             text NOT NULL,
--   option_d             text NOT NULL,
--   correct_option       char(1) NOT NULL,
--   explanation          text NOT NULL,
--   linked_article_title text,
--   difficulty           text DEFAULT 'medium',
--   updated_at           timestamptz DEFAULT now()
-- );

-- ─────────────────────────────────────────────────────────────
-- ADMIN HELPER FUNCTION
-- ─────────────────────────────────────────────────────────────

-- CREATE OR REPLACE FUNCTION public.is_user_admin(uid uuid)
-- RETURNS boolean LANGUAGE sql SECURITY DEFINER AS $$
--   SELECT EXISTS (
--     SELECT 1 FROM profiles WHERE id = uid AND student_type = 'admin'
--   );
-- $$;

-- ─────────────────────────────────────────────────────────────
-- USEFUL ADMIN QUERIES
-- ─────────────────────────────────────────────────────────────

-- Total articles:
-- SELECT COUNT(*) FROM articles;

-- By category:
-- SELECT category, COUNT(*) FROM articles GROUP BY category ORDER BY count DESC;

-- Activate user 365 days:
-- UPDATE subscriptions
-- SET status='active', expiry_date=now()+interval'365 days', activated_at=now()
-- WHERE user_id=(SELECT id FROM auth.users WHERE email='EMAIL');

-- Check all subs:
-- SELECT u.email, s.status, s.expiry_date
-- FROM subscriptions s JOIN auth.users u ON s.user_id=u.id
-- ORDER BY s.activated_at DESC;

-- Missing ethiopianContext:-- SELECT title, category FROM articles
-- WHERE content->>'ethiopianContext' IS NULL OR content->>'ethiopianContext'=''
-- ORDER BY category;