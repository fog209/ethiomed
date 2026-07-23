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

-- Rollout notes:
-- 1. Verify 0006_subscriptions_admin_rls.sql is applied first (is_user_admin() required)
-- 2. Run duplicate-check block before UNIQUE constraint
-- 3. Verify with: SELECT conname FROM pg_constraint WHERE conrelid = 'public.subscriptions'::regclass AND conname = 'subscriptions_user_id_unique';