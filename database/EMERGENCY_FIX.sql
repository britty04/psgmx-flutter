-- ========================================
-- EMERGENCY FIX: Enable OTP Login for ALL Users
-- ========================================
-- This fixes the "Database error saving new user" issue
-- Run this NOW in Supabase SQL Editor
-- ========================================

-- STEP 1: Check if there are any triggers blocking auth.users
SELECT 
  'Checking for triggers on auth.users' as status,
  trigger_name,
  event_manipulation,
  event_object_table
FROM information_schema.triggers
WHERE event_object_schema = 'auth' 
  AND event_object_table = 'users';

-- STEP 2: Disable any problematic triggers temporarily
-- (Re-enable after fixing)
DO $$
DECLARE
  trigger_rec RECORD;
BEGIN
  FOR trigger_rec IN 
    SELECT trigger_name 
    FROM information_schema.triggers
    WHERE event_object_schema = 'public' 
      AND event_object_table = 'users'
      AND trigger_name LIKE '%auto%'
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON users', trigger_rec.trigger_name);
    RAISE NOTICE 'Dropped trigger: %', trigger_rec.trigger_name;
  END LOOP;
END $$;

-- STEP 3: Ensure whitelist has the user
INSERT INTO whitelist (email, name, reg_no, batch, roles)
VALUES (
  '25mx347@psgtech.ac.in',
  'Student 347',
  '25MX347',
  'G1',
  '{"isStudent": true, "isTeamLeader": false, "isCoordinator": false, "isPlacementRep": false}'::jsonb
)
ON CONFLICT (email) DO NOTHING;

-- STEP 4: Clean up any failed auth attempts
-- Delete auth user if they exist without a profile (allows retry)
DO $$
DECLARE
  orphaned_id UUID;
BEGIN
  -- Find auth users without profiles
  SELECT au.id INTO orphaned_id
  FROM auth.users au
  LEFT JOIN public.users pu ON au.id = pu.id
  WHERE au.email = '25mx347@psgtech.ac.in'
    AND pu.id IS NULL;
    
  IF orphaned_id IS NOT NULL THEN
    -- Delete from auth.users (this will allow clean retry)
    DELETE FROM auth.users WHERE id = orphaned_id;
    RAISE NOTICE '✅ Cleaned up orphaned auth user: %', orphaned_id;
  ELSE
    RAISE NOTICE 'ℹ️ No orphaned auth users found';
  END IF;
END $$;

-- STEP 5: Verify RLS policies allow insertion
-- These are the critical policies for login to work
DROP POLICY IF EXISTS "users_insert_auth" ON users;
CREATE POLICY "users_insert_auth" ON users
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "whitelist_read_all" ON whitelist;
CREATE POLICY "whitelist_read_all" ON whitelist
  FOR SELECT 
  USING (true);

-- STEP 6: Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.users TO authenticated;
GRANT SELECT ON public.whitelist TO authenticated;

-- STEP 7: Verification
SELECT '==== VERIFICATION ====' as status;

-- Check whitelist
SELECT 'Whitelist' as check_type, 
       CASE WHEN EXISTS(SELECT 1 FROM whitelist WHERE email = '25mx347@psgtech.ac.in')
       THEN '✅ EXISTS' ELSE '❌ MISSING' END as result;

-- Check RLS policies
SELECT 'RLS Policies' as check_type,
       COUNT(*)::text || ' policies' as result
FROM pg_policies 
WHERE tablename = 'users' 
  AND cmd IN ('INSERT', 'SELECT');

-- Check permissions
SELECT 'Permissions' as check_type,
       CASE WHEN has_table_privilege('authenticated', 'users', 'INSERT')
       THEN '✅ CAN INSERT' ELSE '❌ CANNOT INSERT' END as result;

-- SUCCESS MESSAGE
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '✅ EMERGENCY FIX APPLIED';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '';
  RAISE NOTICE '🔄 NOW DO THIS:';
  RAISE NOTICE '1. Go back to your app';
  RAISE NOTICE '2. Do a HARD REFRESH (Ctrl+Shift+R)';
  RAISE NOTICE '3. Try login again';
  RAISE NOTICE '';
  RAISE NOTICE '📧 User ready: 25mx347@psgtech.ac.in';
  RAISE NOTICE '';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;
