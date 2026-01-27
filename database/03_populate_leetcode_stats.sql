-- ========================================
-- POPULATE LEETCODE STATS TABLE
-- Insert all 123 students' LeetCode usernames
-- ========================================
-- Execute this SQL in Supabase SQL Editor AFTER 02_insert_data.sql
-- ========================================

-- Insert all LeetCode usernames from whitelist into leetcode_stats
-- This creates placeholder entries that the fetch script will update
INSERT INTO public.leetcode_stats (username, total_solved, easy_solved, medium_solved, hard_solved, ranking)
SELECT 
    leetcode_username,
    0, -- total_solved (will be updated by fetch)
    0, -- easy_solved
    0, -- medium_solved
    0, -- hard_solved
    0  -- ranking
FROM public.whitelist
WHERE leetcode_username IS NOT NULL
ON CONFLICT (username) DO UPDATE SET
    -- Keep existing stats if username already exists
    username = EXCLUDED.username;

-- Verification: Count LeetCode stats entries
DO $$
DECLARE
    stats_count INT;
    whitelist_leetcode_count INT;
BEGIN
    SELECT COUNT(*) INTO stats_count FROM public.leetcode_stats;
    SELECT COUNT(*) INTO whitelist_leetcode_count FROM public.whitelist WHERE leetcode_username IS NOT NULL;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ LEETCODE STATS POPULATED!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'LeetCode stats entries: %', stats_count;
    RAISE NOTICE 'Students with LeetCode: %', whitelist_leetcode_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Expected: % entries', whitelist_leetcode_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Next Step:';
    RAISE NOTICE '  The app will auto-fetch real stats from LeetCode API';
    RAISE NOTICE '  Stats refresh: Every 24 hours';
    RAISE NOTICE '========================================';
END $$;
