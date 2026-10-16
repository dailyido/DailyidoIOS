-- =====================================================
-- Daily I Do - User-created To-Dos
-- Run this in Supabase SQL Editor (Database > SQL Editor)
-- =====================================================
--
-- Adds a table for to-dos that users write themselves and
-- attach to one of the checklist timeframe sections
-- (month_category matches the MonthCategory rawValues used
-- in the app, e.g. "12+ months", "Final Month", "Wedding week").
--
-- Follows the same no-Supabase-Auth pattern as the other
-- user_* tables: RLS enabled, all operations allowed, and
-- the app filters by user_id in code.
--
-- Safe to re-run.
-- =====================================================

CREATE TABLE IF NOT EXISTS user_todos (
    id             uuid PRIMARY KEY,
    user_id        uuid NOT NULL,
    title          text NOT NULL,
    note           text,
    month_category text NOT NULL,
    completed_at   timestamptz,
    created_at     timestamptz NOT NULL DEFAULT now()
);

-- Fast lookups of a user's to-dos
CREATE INDEX IF NOT EXISTS user_todos_user_id_idx ON user_todos (user_id);

-- =====================================================
-- Row Level Security
-- =====================================================
ALTER TABLE user_todos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow read user todos"   ON user_todos;
DROP POLICY IF EXISTS "Allow insert user todos" ON user_todos;
DROP POLICY IF EXISTS "Allow update user todos" ON user_todos;
DROP POLICY IF EXISTS "Allow delete user todos" ON user_todos;

CREATE POLICY "Allow read user todos"
ON user_todos FOR SELECT
USING (true);

CREATE POLICY "Allow insert user todos"
ON user_todos FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow update user todos"
ON user_todos FOR UPDATE
USING (true);

CREATE POLICY "Allow delete user todos"
ON user_todos FOR DELETE
USING (true);

-- =====================================================
-- Verify:
-- SELECT tablename, rowsecurity FROM pg_tables
-- WHERE schemaname = 'public' AND tablename = 'user_todos';
-- =====================================================
