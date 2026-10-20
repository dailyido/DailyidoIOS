-- =====================================================
-- Daily I Do - Row Level Security (RLS) Policies
-- Run this in Supabase SQL Editor (Database > SQL Editor)
-- =====================================================
--
-- IMPORTANT: Run the verification query at the bottom
-- after executing to confirm all tables have RLS enabled.
--
-- These policies are designed for a setup where:
--   - No Supabase Auth is used (local UUID-based auth)
--   - All client access uses the anon key
--   - Content tables are read-only from the client
--   - User tables are filtered by user_id in app code
--
-- Because there is no Supabase Auth, we cannot use
-- auth.uid() in policies. Instead we:
--   1. Block writes on content tables (SELECT only)
--   2. Allow all operations on user tables (filtered in app)
--   3. Allow INSERT only on analytics (append-only)
--
-- Safe to re-run: drops any existing policies first.
-- =====================================================


-- =====================================================
-- CONTENT TABLES (read-only from the client)
-- No INSERT/UPDATE/DELETE policies = writes are blocked
-- =====================================================

-- 1. WEDDING_TIPS
ALTER TABLE wedding_tips ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read active tips" ON wedding_tips;
DROP POLICY IF EXISTS "Anyone can read wedding tips" ON wedding_tips;

CREATE POLICY "Anyone can read wedding tips"
ON wedding_tips FOR SELECT
USING (true);

-- 2. FUN_TIPS
ALTER TABLE fun_tips ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read active fun tips" ON fun_tips;
DROP POLICY IF EXISTS "Anyone can read fun tips" ON fun_tips;

CREATE POLICY "Anyone can read fun tips"
ON fun_tips FOR SELECT
USING (true);

-- 3. REMOTE_POPUPS
ALTER TABLE remote_popups ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read active popups" ON remote_popups;
DROP POLICY IF EXISTS "Anyone can read popups" ON remote_popups;

CREATE POLICY "Anyone can read popups"
ON remote_popups FOR SELECT
USING (true);

-- 4. APP_CONFIG
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read active config" ON app_config;
DROP POLICY IF EXISTS "Anyone can read app config" ON app_config;

CREATE POLICY "Anyone can read app config"
ON app_config FOR SELECT
USING (true);

-- 5. SCHEDULED_NOTIFICATIONS
ALTER TABLE scheduled_notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can read active notifications" ON scheduled_notifications;
DROP POLICY IF EXISTS "Anyone can read notifications" ON scheduled_notifications;

CREATE POLICY "Anyone can read notifications"
ON scheduled_notifications FOR SELECT
USING (true);


-- =====================================================
-- USER TABLES (read + write from the client)
-- Without Supabase Auth, we cannot restrict by auth.uid()
-- so policies allow all operations. App filters by user_id.
-- =====================================================

-- 6. USERS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Allow read users" ON users;
DROP POLICY IF EXISTS "Allow insert users" ON users;
DROP POLICY IF EXISTS "Allow update users" ON users;

CREATE POLICY "Allow read users"
ON users FOR SELECT
USING (true);

CREATE POLICY "Allow insert users"
ON users FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow update users"
ON users FOR UPDATE
USING (true);

-- 7. USER_CHECKLIST
ALTER TABLE user_checklist ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can read own checklist" ON user_checklist;
DROP POLICY IF EXISTS "Users can insert checklist items" ON user_checklist;
DROP POLICY IF EXISTS "Users can update own checklist" ON user_checklist;
DROP POLICY IF EXISTS "Users can delete own checklist items" ON user_checklist;
DROP POLICY IF EXISTS "Allow read user checklist" ON user_checklist;
DROP POLICY IF EXISTS "Allow insert user checklist" ON user_checklist;
DROP POLICY IF EXISTS "Allow delete user checklist" ON user_checklist;

CREATE POLICY "Allow read user checklist"
ON user_checklist FOR SELECT
USING (true);

CREATE POLICY "Allow insert user checklist"
ON user_checklist FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow delete user checklist"
ON user_checklist FOR DELETE
USING (true);

-- 8. USER_FAVORITES
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow read user favorites" ON user_favorites;
DROP POLICY IF EXISTS "Allow insert user favorites" ON user_favorites;
DROP POLICY IF EXISTS "Allow delete user favorites" ON user_favorites;

CREATE POLICY "Allow read user favorites"
ON user_favorites FOR SELECT
USING (true);

CREATE POLICY "Allow insert user favorites"
ON user_favorites FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow delete user favorites"
ON user_favorites FOR DELETE
USING (true);

-- 9. USER_FUN_TIPS_SHOWN
ALTER TABLE user_fun_tips_shown ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can read own shown tips" ON user_fun_tips_shown;
DROP POLICY IF EXISTS "Users can insert shown tips" ON user_fun_tips_shown;
DROP POLICY IF EXISTS "Users can update own shown tips" ON user_fun_tips_shown;
DROP POLICY IF EXISTS "Users can delete own shown tips" ON user_fun_tips_shown;
DROP POLICY IF EXISTS "Allow read user fun tips shown" ON user_fun_tips_shown;
DROP POLICY IF EXISTS "Allow insert user fun tips shown" ON user_fun_tips_shown;
DROP POLICY IF EXISTS "Allow update user fun tips shown" ON user_fun_tips_shown;
DROP POLICY IF EXISTS "Allow delete user fun tips shown" ON user_fun_tips_shown;

CREATE POLICY "Allow read user fun tips shown"
ON user_fun_tips_shown FOR SELECT
USING (true);

CREATE POLICY "Allow insert user fun tips shown"
ON user_fun_tips_shown FOR INSERT
WITH CHECK (true);

CREATE POLICY "Allow update user fun tips shown"
ON user_fun_tips_shown FOR UPDATE
USING (true);

CREATE POLICY "Allow delete user fun tips shown"
ON user_fun_tips_shown FOR DELETE
USING (true);


-- =====================================================
-- ANALYTICS TABLE (append-only from the client)
-- Only INSERT allowed - no read/update/delete via anon key
-- =====================================================

-- 10. ANALYTICS_EVENTS
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow insert analytics events" ON analytics_events;

CREATE POLICY "Allow insert analytics events"
ON analytics_events FOR INSERT
WITH CHECK (true);


-- =====================================================
-- VERIFICATION QUERY
-- Run this after to verify RLS is enabled on all tables.
-- Every table should show rowsecurity = true.
-- =====================================================
-- SELECT tablename, rowsecurity
-- FROM pg_tables
-- WHERE schemaname = 'public'
-- ORDER BY tablename;
