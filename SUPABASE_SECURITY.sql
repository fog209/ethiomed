-- EXECUTE THIS IN THE SUPABASE SQL EDITOR BEFORE RELEASING THE APK

-- Enable Row Level Security for all content tables
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_table ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcard_table ENABLE ROW LEVEL SECURITY;

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

-- Policy for flashcard_table: allow anon SELECT only
CREATE POLICY IF NOT EXISTS "flashcard_anon_select" ON flashcard_table
FOR SELECT TO anon USING (true);

CREATE POLICY IF NOT EXISTS "flashcard_anon_insert_block" ON flashcard_table
FOR INSERT TO anon USING (false);

CREATE POLICY IF NOT EXISTS "flashcard_anon_update_block" ON flashcard_table
FOR UPDATE TO anon USING (false);

CREATE POLICY IF NOT EXISTS "flashcard_anon_delete_block" ON flashcard_table
FOR DELETE TO anon USING (false);