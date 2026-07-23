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

-- Rollout notes:
-- 1. Verify 0006_subscriptions_admin_rls.sql is applied first (is_user_admin() required)
-- 2. Verify with: SELECT policyname, cmd FROM pg_policies WHERE tablename = 'user_reports';
-- 3. Verify trigger: SELECT tgname FROM pg_trigger WHERE tgrelid = 'public.user_reports'::regclass AND tgname = 'trg_user_reports_updated_at';