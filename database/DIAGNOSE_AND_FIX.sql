-- ========================================
-- DIAGNOSTIC: Fix Login Issue for Existing User
-- ========================================
-- Run this to diagnose and fix the 25mx347 login issue
-- ========================================

-- STEP 1: Check current status
SELECT '==== WHITELIST CHECK ====' as status;
SELECT * FROM whitelist WHERE email = '25mx347@psgtech.ac.in';

SELECT '==== USER PROFILE CHECK ====' as status;
SELECT * FROM users WHERE email = '25mx347@psgtech.ac.in';

SELECT '==== AUTH USER CHECK ====' as status;
SELECT id, email, created_at, confirmed_at 
FROM auth.users 
WHERE email = '25mx347@psgtech.ac.in';

-- STEP 2: Check if there's a mismatch (auth user but no profile)
SELECT '==== ORPHANED AUTH USERS ====' as status;
SELECT 
  au.id,
  au.email,
  au.created_at,
  CASE 
    WHEN pu.id IS NULL THEN '❌ NO PROFILE - THIS IS THE ISSUE'
    ELSE '✅ HAS PROFILE'
  END as status
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE au.email = '25mx347@psgtech.ac.in';

-- STEP 3: If user exists in auth but not in users, create the profile manually
DO $$
DECLARE
  auth_user_id UUID;
  whitelist_record RECORD;
  profile_exists BOOLEAN;
BEGIN
  -- Get auth user ID
  SELECT id INTO auth_user_id 
  FROM auth.users 
  WHERE email = '25mx347@psgtech.ac.in';
  
  IF auth_user_id IS NULL THEN
    RAISE NOTICE '⚠️ User not found in auth.users - they need to complete OTP verification first';
    RETURN;
  END IF;
  
  -- Check if profile exists
  SELECT EXISTS(SELECT 1 FROM users WHERE id = auth_user_id) INTO profile_exists;
  
  IF profile_exists THEN
    RAISE NOTICE '✅ Profile already exists - login should work';
    RETURN;
  END IF;
  
  RAISE NOTICE '🔧 Profile missing - creating now...';
  
  -- Get whitelist data
  SELECT * INTO whitelist_record FROM whitelist WHERE email = '25mx347@psgtech.ac.in';
  
  IF NOT FOUND THEN
    RAISE NOTICE '❌ User not in whitelist - cannot create profile';
    RETURN;
  END IF;
  
  -- Create the user profile
  INSERT INTO users (
    id, 
    email, 
    reg_no, 
    name, 
    batch, 
    team_id, 
    roles,
    dob,
    leetcode_username,
    birthday_notifications_enabled,
    leetcode_notifications_enabled
  )
  VALUES (
    auth_user_id,
    whitelist_record.email,
    whitelist_record.reg_no,
    whitelist_record.name,
    whitelist_record.batch,
    whitelist_record.team_id,
    whitelist_record.roles,
    whitelist_record.dob,
    whitelist_record.leetcode_username,
    true,
    true
  );
  
  RAISE NOTICE '✅ Profile created successfully!';
  RAISE NOTICE '📧 User can now login: %', whitelist_record.email;
  
EXCEPTION
  WHEN unique_violation THEN
    RAISE NOTICE '⚠️ Unique constraint violation - reg_no might be duplicate';
    -- Try with modified reg_no
    INSERT INTO users (
      id, 
      email, 
      reg_no, 
      name, 
      batch, 
      team_id, 
      roles,
      birthday_notifications_enabled,
      leetcode_notifications_enabled
    )
    VALUES (
      auth_user_id,
      '25mx347@psgtech.ac.in',
      '25MX347_' || substring(auth_user_id::text, 1, 4),
      whitelist_record.name,
      whitelist_record.batch,
      whitelist_record.team_id,
      whitelist_record.roles,
      true,
      true
    );
    RAISE NOTICE '✅ Profile created with modified reg_no';
  WHEN OTHERS THEN
    RAISE NOTICE '❌ Error: %', SQLERRM;
END $$;

-- STEP 4: Verify the fix
SELECT '==== FINAL VERIFICATION ====' as status;
SELECT 
  u.id,
  u.email,
  u.name,
  u.reg_no,
  u.batch,
  u.team_id,
  u.roles,
  '✅ READY TO LOGIN' as status
FROM users u
WHERE u.email = '25mx347@psgtech.ac.in';

-- STEP 5: Check RLS policies
SELECT '==== RLS POLICIES ====' as status;
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN cmd = 'INSERT' AND with_check = '(auth.uid() = id)' THEN '✅ CORRECT'
    WHEN cmd = 'SELECT' THEN '✅ CORRECT'
    ELSE '⚠️ CHECK POLICY'
  END as policy_status
FROM pg_policies
WHERE tablename = 'users'
ORDER BY cmd, policyname;

-- FINAL MESSAGE
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '🎯 DIAGNOSTIC COMPLETE';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE 'Check the results above to see what was fixed.';
  RAISE NOTICE 'If you see ✅ READY TO LOGIN, refresh your app and try again.';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;
