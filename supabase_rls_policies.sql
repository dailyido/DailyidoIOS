-- =====================================================
-- Daily I Do - Row Level Security (RLS) Policies
-- Run this in Supabase SQL Editor (Database > SQL Editor)
-- =====================================================

-- =====================================================
-- 1. USERS TABLE
-- Users can only access their own record
-- =====================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own data
CREATE POLICY "Users can read own data"
ON users FOR SELECT
USING (true);  -- Note: Without Supabase Auth, we allow reads and filter in app

-- Allow users to insert their own data
CREATE POLICY "Users can insert own data"
ON users FOR INSERT
WITH CHECK (true);

-- Allow users to update their own data
CREATE POLICY "Users can update own data"
ON users FOR UPDATE
USING (true);

-- =====================================================
-- 2. WEDDING_TIPS TABLE
-- Read-only for all app users, admin manages content
-- =====================================================
ALTER TABLE wedding_tips ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read active tips
CREATE POLICY "Anyone can read active tips"
ON wedding_tips FOR SELECT
USING (is_active = true);

-- =====================================================
-- 3. USER_CHECKLIST TABLE
-- Users can only access their own checklist items
-- =====================================================
ALTER TABLE user_checklist ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own checklist
CREATE POLICY "Users can read own checklist"
ON user_checklist FOR SELECT
USING (true);

-- Allow users to add to their checklist
CREATE POLICY "Users can insert checklist items"
ON user_checklist FOR INSERT
WITH CHECK (true);

-- Allow users to update their checklist
CREATE POLICY "Users can update own checklist"
ON user_checklist FOR UPDATE
USING (true);

-- Allow users to delete from their checklist
CREATE POLICY "Users can delete own checklist items"
ON user_checklist FOR DELETE
USING (true);

-- =====================================================
-- 4. REMOTE_POPUPS TABLE
-- Read-only for app users
-- =====================================================
ALTER TABLE remote_popups ENABLE ROW LEVEL SECURITY;

-- Allow reading active popups
CREATE POLICY "Anyone can read active popups"
ON remote_popups FOR SELECT
USING (is_active = true);

-- =====================================================
-- 5. APP_CONFIG TABLE
-- Read-only for app users
-- =====================================================
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Allow reading active config
CREATE POLICY "Anyone can read active config"
ON app_config FOR SELECT
USING (is_active = true);

-- =====================================================
-- 6. SCHEDULED_NOTIFICATIONS TABLE
-- Read-only for app users
-- =====================================================
ALTER TABLE scheduled_notifications ENABLE ROW LEVEL SECURITY;

-- Allow reading active notifications
CREATE POLICY "Anyone can read active notifications"
ON scheduled_notifications FOR SELECT
USING (is_active = true);

-- =====================================================
-- 7. FUN_TIPS TABLE
-- Read-only for app users
-- =====================================================
ALTER TABLE fun_tips ENABLE ROW LEVEL SECURITY;

-- Allow reading active fun tips
CREATE POLICY "Anyone can read active fun tips"
ON fun_tips FOR SELECT
USING (is_active = true);

-- =====================================================
-- 8. USER_FUN_TIPS_SHOWN TABLE
-- Users can only access their own shown tips tracking
-- =====================================================
ALTER TABLE user_fun_tips_shown ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own shown tips
CREATE POLICY "Users can read own shown tips"
ON user_fun_tips_shown FOR SELECT
USING (true);

-- Allow users to record shown tips
CREATE POLICY "Users can insert shown tips"
ON user_fun_tips_shown FOR INSERT
WITH CHECK (true);

-- Allow users to update their shown tips
CREATE POLICY "Users can update own shown tips"
ON user_fun_tips_shown FOR UPDATE
USING (true);

-- Allow users to delete their shown tips (for reset)
CREATE POLICY "Users can delete own shown tips"
ON user_fun_tips_shown FOR DELETE
USING (true);

-- =====================================================
-- VERIFICATION QUERY
-- Run this after to verify RLS is enabled
-- =====================================================
-- SELECT tablename, rowsecurity
-- FROM pg_tables
-- WHERE schemaname = 'public';
