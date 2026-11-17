-- =====================================================
-- Daily I Do - Timeline Builder
-- Run this in Supabase SQL Editor (Database > SQL Editor)
-- =====================================================
--
-- One row per user holding their Timeline Builder answers
-- (questionnaire) and their edits to the generated timeline
-- (overrides: pinned times, hidden lines, reordered moments).
-- The timeline itself is generated in the app from these.
--
-- Follows the same no-Supabase-Auth pattern as the other
-- user_* tables: RLS enabled, all operations allowed, and
-- the app filters by user_id in code.
--
-- Safe to re-run.
-- =====================================================

CREATE TABLE IF NOT EXISTS wedding_timelines (
    user_id            uuid PRIMARY KEY,
    questionnaire      jsonb NOT NULL DEFAULT '{}'::jsonb,
    overrides          jsonb NOT NULL DEFAULT '{}'::jsonb,
    first_look_choice  text,          -- 'yes' | 'no' | 'both'
    updated_at         timestamptz NOT NULL DEFAULT now(),
    created_at         timestamptz NOT NULL DEFAULT now()
);

-- =====================================================
-- Row Level Security
-- =====================================================
ALTER TABLE wedding_timelines ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow read wedding timelines"   ON wedding_timelines;
DROP POLICY IF EXISTS "Allow insert wedding timelines" ON wedding_timelines;
DROP POLICY IF EXISTS "Allow update wedding timelines" ON wedding_timelines;

CREATE POLICY "Allow read wedding timelines"
ON wedding_timelines FOR SELECT
USING (true);

CREATE POLICY "Allow insert wedding timelines"
ON wedding_timelines FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow update wedding timelines"
ON wedding_timelines FOR UPDATE
USING (true);

-- =====================================================
-- Verify:
-- SELECT tablename, rowsecurity FROM pg_tables
-- WHERE schemaname = 'public' AND tablename = 'wedding_timelines';
-- =====================================================
