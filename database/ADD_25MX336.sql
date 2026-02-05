-- ========================================
-- ADD 25mx336 TO WHITELIST AND TEST
-- ========================================
-- Run this entire script in Supabase SQL Editor
-- ========================================

-- STEP 1: Add 25mx336 to whitelist
INSERT INTO public.whitelist (email, name, reg_no, batch, team_id, dob, leetcode_username, roles)
VALUES (
    '25mx336@psgtech.ac.in',
    'Nitheesh Muthu Krishnan C',
    '25MX336',
    'G2',
    'T07',
    '2005-07-05',
    'nitheeshmk5',
    '{"isStudent": true, "isTeamLeader": true, "isCoordinator": true, "isPlacementRep": false}'::jsonb
)
ON CONFLICT (email) DO UPDATE SET
    name = EXCLUDED.name,
    reg_no = EXCLUDED.reg_no,
    batch = EXCLUDED.batch,
    team_id = EXCLUDED.team_id,
    dob = EXCLUDED.dob,
    leetcode_username = EXCLUDED.leetcode_username,
    roles = EXCLUDED.roles;

-- STEP 2: Clean up any orphaned auth users
DELETE FROM auth.users
WHERE email = '25mx336@psgtech.ac.in'
  AND NOT EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.users.id
  );

-- STEP 3: Verify whitelist entry
SELECT 
    '✅ WHITELIST CHECK' as status,
    email,
    name,
    reg_no,
    roles
FROM public.whitelist
WHERE email = '25mx336@psgtech.ac.in';

-- STEP 4: Check if user profile already exists
SELECT 
    '📊 USER PROFILE CHECK' as status,
    id,
    email,
    name,
    reg_no
FROM public.users
WHERE email = '25mx336@psgtech.ac.in';

-- STEP 5: Check auth users table
SELECT 
    '🔐 AUTH USERS CHECK' as status,
    id,
    email,
    created_at,
    email_confirmed_at
FROM auth.users
WHERE email = '25mx336@psgtech.ac.in';

-- ========================================
-- VERIFICATION
-- ========================================
DO $$
DECLARE
    whitelist_exists BOOL;
    user_exists BOOL;
    auth_exists BOOL;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM public.whitelist WHERE email = '25mx336@psgtech.ac.in'
    ) INTO whitelist_exists;
    
    SELECT EXISTS (
        SELECT 1 FROM public.users WHERE email = '25mx336@psgtech.ac.in'
    ) INTO user_exists;
    
    SELECT EXISTS (
        SELECT 1 FROM auth.users WHERE email = '25mx336@psgtech.ac.in'
    ) INTO auth_exists;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ SETUP COMPLETE FOR 25mx336';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Whitelist entry: %', CASE WHEN whitelist_exists THEN '✅ EXISTS' ELSE '❌ MISSING' END;
    RAISE NOTICE 'User profile: %', CASE WHEN user_exists THEN '✅ EXISTS' ELSE '⚠️ WILL BE CREATED BY TRIGGER' END;
    RAISE NOTICE 'Auth user: %', CASE WHEN auth_exists THEN '⚠️ EXISTS (may have old data)' ELSE '✅ CLEAN (ready for fresh login)' END;
    RAISE NOTICE '';
    RAISE NOTICE '🎯 READY TO TEST:';
    RAISE NOTICE '1. Enter: 25mx336@psgtech.ac.in';
    RAISE NOTICE '2. Click: Get OTP';
    RAISE NOTICE '3. Check: Email for 6-digit code';
    RAISE NOTICE '4. Enter: Code in app';
    RAISE NOTICE '5. Result: Should login successfully';
    RAISE NOTICE '========================================';
END $$;
