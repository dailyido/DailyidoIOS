-- =====================================================
-- Add new columns to tips tables
-- Run this in Supabase SQL Editor (Database > SQL Editor)
-- =====================================================

-- Add category column to wedding_tips table
ALTER TABLE wedding_tips ADD COLUMN IF NOT EXISTS category TEXT;

-- Add priority column to fun_tips table (for showing priority 1 tips first)
ALTER TABLE fun_tips ADD COLUMN IF NOT EXISTS priority INTEGER;

-- Verify the columns were added
SELECT 'wedding_tips' as table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'wedding_tips'
AND column_name = 'category'
UNION ALL
SELECT 'fun_tips' as table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'fun_tips'
AND column_name = 'priority';
