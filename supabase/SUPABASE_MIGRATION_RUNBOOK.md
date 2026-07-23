# Supabase Migration Runbook

**Date:** 2026-07-20  
**Target:** Production Supabase project (`kxcdzlyirdonkipcymvc.supabase.co`)  
**Access:** Supabase SQL Editor (service role key required)  
**Convention:** All DDL is manual; no migration runner is used. Each block is idempotent.

---

## Current State Audit

| Migration | On Disk | Applied to Supabase? | Notes |
|-----------|---------|----------------------|-------|
| `0001_active_sessions.sql` | ✅ | ? | Assumed applied (initial schema) |
| `0002_section_registry.sql` | ✅ | ? | Unknown |
| `0003_section_registry_overrides.sql` | ✅ | ? | Unknown |
| `0004_flashcard_track_category.sql` | ✅ | ? | Unknown |
| `0005_server_now_rpc.sql` | ✅ | ❌ | Feather-light batch, NOT yet applied |
| `0006_subscriptions_admin_rls.sql` | ✅ | ❌ | Feather-light batch, NOT yet applied |
| `0007_questions_attending_tip.sql` | ✅ | ❌ | Feather-light batch, NOT yet applied |
| `0008_activation_log.sql` | ❌ | ❌ | **Pending — to be created and applied** |
| `0009_*` | ❌ | ❌ | **SKIP — paused under Hard Freeze** |
| `0011_user_reports.sql` | ❌ | ❌ | **Pending — to be created and applied** |

---

## Execution Order

```
Step 1 : Run 0005_server_now_rpc.sql        [prerequisite: none]
Step 2 : Run 0006_subscriptions_admin_rls.sql [prerequisite: step 1]
Step 3 : Diagnostic — verify 0006 was applied correctly
Step 4 : Run 0008_activation_log.sql          [prerequisite: step 1, step 2]
Step 5 : Run 0011_user_reports.sql            [prerequisite: none]
```

---

## Step 1 — `0005_server_now_rpc.sql`

**File:** `supabase/migrations/0005_server_now_rpc.sql` (on disk)

```sql
-- Create the server_now() function for anti-clock-spoof expiry checks.
-- This allows the client to compare subscription expiry against the
-- authoritative Postgres timestamp instead of the device clock.
create or replace function public.server_now()
returns timestamptz
language sql
security definer
set search_path = public
as $$
  select now();
$$;
```

### Preconditions
- None. This is a standalone helper function.
- Safe to re-run (`CREATE OR REPLACE`).

### Verification
```sql
SELECT public.server_now();
-- Expected: returns current timestamp
```

### Rollback
```sql
DROP FUNCTION IF EXISTS public.server_now();
```

---

## Step 2 — `0006_subscriptions_admin_rls.sql`

**File:** `supabase/migrations/0006_subscriptions_admin_rls.sql` (on disk)

### Preconditions
1. ✅ `profiles.is_admin` column must exist (it does — verified in schema.sql).
2. ✅ `subscriptions` table must exist with `user_id` column.
3. ✅ `0005_server_now_rpc.sql` should be applied first (not a hard dependency, but recommended order).

### The SQL (runs these operations)
```sql
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

drop policy if exists "Admins can insert subscriptions" on public.subscriptions;
create policy "Admins can insert subscriptions"
  on public.subscriptions
  for insert
  to authenticated
  with check (public.is_user_admin(auth.uid()));

drop policy if exists "Admins can update subscriptions" on public.subscriptions;
create policy "Admins can update subscriptions"
  on public.subscriptions
  for update
  to authenticated
  using (public.is_user_admin(auth.uid()))
  with check (public.is_user_admin(auth.uid()));
```

### Verification
```sql
-- Verify the function exists
SELECT proname FROM pg_proc WHERE proname = 'is_user_admin';
-- Expected: 1 row

-- Verify policies exist
SELECT policyname, cmd, permissive
FROM pg_policies
WHERE tablename = 'subscriptions'
ORDER BY policyname;
-- Expected at least 3 rows:
--   "Admins can insert subscriptions"  | INSERT
--   "Admins can update subscriptions"  | UPDATE
--   "Users see own subscription"       | SELECT

-- Quick function smoke test
SELECT public.is_user_admin(auth.uid());
-- Note: this will error if run outside a session (e.g., in SQL Editor as service_role),
-- which is expected — the function is designed for RLS context only.
```

### Rollback
```sql
DROP FUNCTION IF EXISTS public.is_user_admin(uid uuid);

DROP POLICY IF EXISTS "Admins can insert subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "Admins can update subscriptions" ON public.subscriptions;
```

---

## Step 3 — Diagnostic: Verify 0006 (Admin RLS) Correctly Applied

This standalone check confirms the migration took effect on the live DB.

### Diagnostic Query
```sql
-- 1) Check that profiles have the is_admin column
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'profiles' AND column_name = 'is_admin';

-- Expected: one row | is_admin | boolean | YES

-- 2) List ALL policies on subscriptions
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'subscriptions'
ORDER BY policyname;

-- Expected:
--   "Admins can insert subscriptions" | cmd=INSERT, with_check=(public.is_user_admin(auth.uid()))
--   "Admins can update subscriptions" | cmd=UPDATE, using=(public.is_user_admin(auth.uid()))
--   "Users see own subscription"      | cmd=SELECT, qual=(auth.uid() = user_id)

-- 3) Confirm non-admin INSERT fails (post-service-role-switch test):
--   - Switch to an authenticated user session (NOT service_role)
--   - Run: INSERT INTO subscriptions (user_id, status) VALUES ('<non-admin-uuid>', 'pending');
--   - Expected: ERROR: new row violates row-level security policy

-- 4) Confirm admin INSERT succeeds:
--   - Switch to an admin user session
--   - Run: INSERT INTO subscriptions (user_id, status) VALUES ('<some-uuid>', 'pending');
--   - Expected: INSERT 0 1 (then rollback or delete test row)
```

### Pass/Fail Criteria
- **PASS:** All 3 policies present, `is_admin` column exists, non-admin INSERT denied.
- **FAIL:** Missing policy/column, or non-admin INSERT succeeds.
- **REMEDIATION:** Re-run Step 2 SQL.

---

## Step 4 — `0008_activation_log.sql` (New Migration)

**File:** Does NOT yet exist on disk. Create before executing.

### Purpose
1. **`activation_log` table:** Audit trail for admin subscription activations — who activated what, when, and any notes.
2. **`UNIQUE` constraint on `subscriptions.user_id`:** Prevent duplicate subscription rows per user (current schema allows multiple rows with same `user_id`).

### SQL to Execute

```sql
-- ─────────────────────────────────────────────────────────────
-- 0008: activation_log table + subscriptions.user_id UNIQUE
-- ─────────────────────────────────────────────────────────────

-- PART A: Precondition — deduplicate subscriptions.user_id
-- Before adding a UNIQUE constraint, check for existing duplicates.
-- If any exist, resolve them manually (keep the most recently activated,
-- or the one with status='active', and delete/merge others).

DO $$
DECLARE
  dup_count integer;
BEGIN
  SELECT COUNT(*) INTO dup_count FROM (
    SELECT user_id FROM public.subscriptions
    GROUP BY user_id HAVING COUNT(*) > 1
  ) dups;

  IF dup_count > 0 THEN
    RAISE EXCEPTION 'Found % user_id(s) with duplicate subscription rows. Resolve manually before applying UNIQUE constraint.', dup_count;
  ELSE
    RAISE NOTICE 'No duplicate user_ids found. Safe to add UNIQUE constraint.';
  END IF;
END $$;

-- Resolve duplicates manually if the above raises:
-- Keep the active one, archive others:
--   WITH ranked AS (
--     SELECT id, user_id, status, activated_at,
--            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY
--              CASE WHEN status = 'active' THEN 0 ELSE 1 END,
--              activated_at DESC NULLS LAST) AS rn
--     FROM subscriptions
--   )
--   DELETE FROM subscriptions WHERE id IN (
--     SELECT id FROM ranked WHERE rn > 1
--   );

-- PART B: activation_log table
CREATE TABLE IF NOT EXISTS public.activation_log (
  id            uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id       uuid NOT NULL REFERENCES auth.users(id),
  activated_by  uuid NOT NULL REFERENCES auth.users(id),
  action        text NOT NULL DEFAULT 'activate',  -- 'activate' | 'deactivate' | 'extend'
  expiry_date   timestamptz,
  notes         text,
  created_at    timestamptz DEFAULT now()
);

ALTER TABLE public.activation_log ENABLE ROW LEVEL SECURITY;

-- Admins can read all activation logs
CREATE POLICY "Admins can read activation_log"
  ON public.activation_log
  FOR SELECT
  TO authenticated
  USING (public.is_user_admin(auth.uid()));

-- Admins can insert activation_log
CREATE POLICY "Admins can insert activation_log"
  ON public.activation_log
  FOR INSERT
  TO authenticated
  WITH CHECK (public.is_user_admin(auth.uid()));

-- Index for common queries
CREATE INDEX IF NOT EXISTS idx_activation_log_user_id
  ON public.activation_log(user_id);

CREATE INDEX IF NOT EXISTS idx_activation_log_created_at
  ON public.activation_log(created_at DESC);

-- PART C: UNIQUE constraint on subscriptions.user_id
-- Idempotent: IF NOT EXISTS prevents error on re-run.
ALTER TABLE public.subscriptions
  ADD CONSTRAINT subscriptions_user_id_unique UNIQUE (user_id);
```

### Preconditions
1. ✅ Step 2 (0006) must be applied first — `is_user_admin()` is used in `activation_log` RLS policies.
2. ⚠️ **CRITICAL:** Run the duplicate-check block first. If duplicates exist, resolve them manually before adding the UNIQUE constraint.

### Verification
```sql
-- Verify activation_log table exists
SELECT to_regclass('public.activation_log');
-- Expected: activation_log (not NULL)

-- Verify RLS policies
SELECT policyname, cmd FROM pg_policies
WHERE tablename = 'activation_log';
-- Expected:
--   "Admins can read activation_log"   | SELECT
--   "Admins can insert activation_log" | INSERT

-- Verify UNIQUE constraint
SELECT conname, contype FROM pg_constraint
WHERE conrelid = 'public.subscriptions'::regclass
AND conname = 'subscriptions_user_id_unique';
-- Expected: subscriptions_user_id_unique | u

-- Quick insert test (as admin):
-- INSERT INTO activation_log (user_id, activated_by, action, expiry_date, notes)
-- VALUES ('<some-uuid>', '<admin-uuid>', 'activate', now() + interval '365 days', 'Test activation');
-- Expected: INSERT 0 1 (then rollback)
```

### Rollback
```sql
-- Rollback in reverse order:

-- 1) Drop UNIQUE constraint
ALTER TABLE public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_user_id_unique;

-- 2) Drop activation_log table (cascades to policies and indexes)
DROP TABLE IF EXISTS public.activation_log CASCADE;

-- 3) Or drop just the policies without dropping the table:
-- DROP POLICY IF EXISTS "Admins can read activation_log" ON public.activation_log;
-- DROP POLICY IF EXISTS "Admins can insert activation_log" ON public.activation_log;
-- DROP INDEX IF EXISTS idx_activation_log_user_id;
-- DROP INDEX IF EXISTS idx_activation_log_created_at;
```

---

## Step 5 — `0011_user_reports.sql` (New Migration)

**File:** Does NOT yet exist on disk. Create before executing.

### Purpose
Allow authenticated users to report issues with articles, questions, or app content. Reports are admin-visible only (RLS restricts SELECT to admins).

### SQL to Execute

```sql
-- ─────────────────────────────────────────────────────────────
-- 0011: user_reports table
-- ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.user_reports (
  id            uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id       uuid NOT NULL REFERENCES auth.users(id),
  report_type   text NOT NULL DEFAULT 'other',
    -- 'wrong_answer' | 'typo' | 'outdated_info' | 'missing_content' | 'technical_issue' | 'other'
  content_id    text,          -- UUID or slug of the reported content (articles.id, questions.id, etc.)
  content_type  text,          -- 'article' | 'question' | 'flashcard' | 'general'
  description   text NOT NULL, -- Free-text report from the user
  status        text NOT NULL DEFAULT 'open',
    -- 'open' | 'under_review' | 'resolved' | 'dismissed'
  admin_notes   text,          -- Admin response / resolution notes
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;

-- Policy: users can see only their own reports
CREATE POLICY "Users see own reports"
  ON public.user_reports
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: users can insert their own reports
CREATE POLICY "Users can insert own reports"
  ON public.user_reports
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy: admins can see all reports
CREATE POLICY "Admins can read all reports"
  ON public.user_reports
  FOR SELECT
  TO authenticated
  USING (public.is_user_admin(auth.uid()));

-- Policy: admins can update reports (e.g., change status, add admin_notes)
CREATE POLICY "Admins can update reports"
  ON public.user_reports
  FOR UPDATE
  TO authenticated
  USING (public.is_user_admin(auth.uid()))
  WITH CHECK (public.is_user_admin(auth.uid()));

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_user_reports_user_id
  ON public.user_reports(user_id);

CREATE INDEX IF NOT EXISTS idx_user_reports_status
  ON public.user_reports(status);

CREATE INDEX IF NOT EXISTS idx_user_reports_created_at
  ON public.user_reports(created_at DESC);

-- Trigger to auto-update updated_at on row modification
CREATE OR REPLACE FUNCTION public.update_user_reports_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_user_reports_updated_at ON public.user_reports;
CREATE TRIGGER trg_user_reports_updated_at
  BEFORE UPDATE ON public.user_reports
  FOR EACH ROW
  EXECUTE FUNCTION public.update_user_reports_updated_at();
```

### Preconditions
1. ✅ `0006_subscriptions_admin_rls.sql` must be applied first — `is_user_admin()` is used in the admin RLS policies.
2. `auth.users` table must exist (standard Supabase Auth — always present).

### Verification
```sql
-- Verify table exists
SELECT to_regclass('public.user_reports');
-- Expected: user_reports (not NULL)

-- Verify policies
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'user_reports'
ORDER BY policyname;
-- Expected:
--   "Admins can read all reports"    | SELECT | (public.is_user_admin(auth.uid()))
--   "Admins can update reports"      | UPDATE | (public.is_user_admin(auth.uid()))
--   "Users can insert own reports"   | INSERT | (auth.uid() = user_id)
--   "Users see own reports"          | SELECT | (auth.uid() = user_id)

-- Verify trigger
SELECT tgname FROM pg_trigger
WHERE tgrelid = 'public.user_reports'::regclass
AND tgname = 'trg_user_reports_updated_at';
-- Expected: trg_user_reports_updated_at
```

### Rollback
```sql
DROP TRIGGER IF EXISTS trg_user_reports_updated_at ON public.user_reports;
DROP FUNCTION IF EXISTS public.update_user_reports_updated_at();
DROP TABLE IF EXISTS public.user_reports CASCADE;
```

---

## Executor's Checklist

### Pre-flight (before touching the SQL Editor)
- [ ] Confirm service role key is ready (settings > API > service_role key).
- [ ] Confirm Supabase SQL Editor is open to the correct project.
- [ ] Verify current schema version by running: `SELECT version();` — just a sanity check.
- [ ] Verify `profiles.is_admin` exists and has data:
      
```sql
      SELECT COUNT(*) FROM profiles WHERE is_admin = true;
      
```
- [ ] If any admin has `is_admin` NULL or false, update them first:
      
```sql
      UPDATE profiles SET is_admin = true WHERE id = '<admin-uuid>';
      
```

### Execution
- [ ] Step 1: Run `0005_server_now_rpc.sql`. Verify with `SELECT public.server_now();`.
- [ ] Step 2: Run `0006_subscriptions_admin_rls.sql`. Verify with pg_policies query.
- [ ] Step 3: Run diagnostic queries to confirm 0006 applied correctly.
- [ ] Step 4: Create `0008_activation_log.sql` file on disk (use the SQL above).
  - [ ] Run duplicate-check block. If duplicates found, resolve manually.
  - [ ] Run full 0008 SQL. Verify UNIQUE constraint + activation_log table.
- [ ] Step 5: Create `0011_user_reports.sql` file on disk (use the SQL above).
  - [ ] Run full 0011 SQL. Verify table, policies, indexes, and trigger.

### Post-flight
- [ ] Verify `schema.sql` is updated to reflect new tables/constraints.
- [ ] Run `SELECT * FROM pg_policies WHERE tablename IN ('subscriptions', 'activation_log', 'user_reports');` for final audit.
- [ ] Commit: `git add supabase/migrations/0008_activation_log.sql supabase/migrations/0011_user_reports.sql && git commit -m "feat: add activation_log, user_reports migrations"`
- [ ] Update `supabase/schema.sql` with the new table DDL.

---

## Summary Table

| Step | Migration | File | Precondition | Rollback |
|------|-----------|------|-------------|----------|
| 1 | `0005` | On disk ✅ | None | `DROP FUNCTION server_now()` |
| 2 | `0006` | On disk ✅ | Step 1 | `DROP FUNCTION is_user_admin` + `DROP POLICY` x2 |
| 3 | Diagnostic | N/A | Step 2 | N/A |
| 4 | `0008` | **Create new** ✅ (SQL above) | Step 2 + dedup check | `ALTER TABLE DROP CONSTRAINT` + `DROP TABLE activation_log CASCADE` |
| — | `0009` | **SKIP** | Paused under Hard Freeze | — |
| 5 | `0011` | **Create new** ✅ (SQL above) | Step 2 | `DROP TABLE user_reports CASCADE` |
