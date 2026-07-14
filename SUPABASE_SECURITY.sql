-- EXECUTE THIS IN THE SUPABASE SQL EDITOR BEFORE RELEASING THE APK

-- Enable Row Level Security for all content tables
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_table ENABLE ROW LEVEL SECURITY;
-- NOTE: the remote flashcards table is named `flashcards` (NOT
-- `flashcard_table`, which is the LOCAL Drift table). Flashcards use a
-- subscription-gated SELECT policy, NOT the anon-select pattern below.
-- See supabase/schema.sql (FLASHCARDS section) for the real policy.

-- Policy for articles: allow anon SELECT only
CREATE POLICY IF NOT EXISTS "articles_anon_select" ON articles
FOR SELECT TO anon USING (true);

CREATE POLICY IF NOT EXISTS "articles_anon_insert_block" ON articles
FOR INSERT TO anon USING (false);

CREATE POLICY IF NOT EXISTS "articles_anon_update_block" ON articles
FOR UPDATE TO anon USING (false);

CREATE POLICY IF NOT EXISTS "articles_anon_delete_block" ON articles
FOR DELETE TO anon USING (false);

-- Policy for quiz_table: allow anon SELECT only
CREATE POLICY IF NOT EXISTS "quiz_anon_select" ON quiz_table
FOR SELECT TO anon USING (true);

CREATE POLICY IF NOT EXISTS "quiz_anon_insert_block" ON quiz_table
FOR INSERT TO anon USING (false);

CREATE POLICY IF NOT EXISTS "quiz_anon_update_block" ON quiz_table
FOR UPDATE TO anon USING (false);

CREATE POLICY IF NOT EXISTS "quiz_anon_delete_block" ON quiz_table
FOR DELETE TO anon USING (false);

-- (removed) flashcard_table anon policies — that table does not exist in
-- the live DB, and remote `flashcards` is subscription-gated, not anon.