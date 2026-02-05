-- ========================================
-- COMPLETE PRODUCTION FIX FOR MAGIC LINK OTP
-- ========================================
-- Run this entire script in Supabase SQL Editor
-- This will enable automatic profile creation
-- ========================================

-- STEP 1: Add student to whitelist
INSERT INTO public.whitelist (email, name, reg_no, batch, team_id, dob, leetcode_username, roles)
VALUES (
    '25mx347@psgtech.ac.in',
    'Sivapradeesh M',
    '25MX347',
    'G2',
    'T11',
    NULL,
    'Sivapradeesh_M',
    '{"isStudent": true, "isTeamLeader": false, "isCoordinator": false, "isPlacementRep": false}'::jsonb
)
ON CONFLICT (email) DO UPDATE SET
    name = EXCLUDED.name,
    reg_no = EXCLUDED.reg_no,
    batch = EXCLUDED.batch,
    team_id = EXCLUDED.team_id,
    dob = EXCLUDED.dob,
    leetcode_username = EXCLUDED.leetcode_username,
    roles = EXCLUDED.roles;

-- STEP 2: Clean up any orphaned auth users from previous failed attempts
DELETE FROM auth.users
WHERE email = '25mx347@psgtech.ac.in'
  AND NOT EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.users.id
  );

-- STEP 3: Drop old trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- STEP 4: Create production-ready trigger function
-- This automatically creates user profile when OTP is verified
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Only create profile if user is in whitelist
  IF EXISTS (SELECT 1 FROM public.whitelist WHERE email = NEW.email) THEN
    
    INSERT INTO public.users (
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
    SELECT 
      NEW.id,
      w.email,
      w.reg_no,
      w.name,
      COALESCE(w.batch, 'G1'),
      w.team_id,
      COALESCE(w.roles, '{"isStudent": true}'::jsonb),
      w.dob,
      w.leetcode_username,
      true,
      true
    FROM public.whitelist w
    WHERE w.email = NEW.email
    ON CONFLICT (id) DO NOTHING;
    
    RAISE LOG 'Profile created for user: %', NEW.email;
  ELSE
    RAISE LOG 'User not in whitelist: %', NEW.email;
  END IF;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't block auth
    RAISE LOG 'Error creating profile for %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- STEP 5: Create trigger that runs AFTER auth user is created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- VERIFICATION
-- ========================================
DO $$
DECLARE
    whitelist_count INT;
    trigger_exists BOOL;
BEGIN
    -- Check whitelist
    SELECT COUNT(*) INTO whitelist_count 
    FROM public.whitelist 
    WHERE email = '25mx347@psgtech.ac.in';
    
    -- Check trigger
    SELECT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'on_auth_user_created'
    ) INTO trigger_exists;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ COMPLETE PRODUCTION FIX APPLIED';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Student in whitelist: %', CASE WHEN whitelist_count > 0 THEN '✅ YES' ELSE '❌ NO' END;
    RAISE NOTICE 'Auto-profile trigger: %', CASE WHEN trigger_exists THEN '✅ ACTIVE' ELSE '❌ NOT FOUND' END;
    RAISE NOTICE '';
    RAISE NOTICE 'MAGIC LINK OTP FLOW:';
    RAISE NOTICE '1. User enters email → System sends OTP to email';
    RAISE NOTICE '2. User receives 6-digit code via email';
    RAISE NOTICE '3. User enters code → Supabase verifies';
    RAISE NOTICE '4. Trigger auto-creates profile from whitelist';
    RAISE NOTICE '5. Login complete → User sees dashboard';
    RAISE NOTICE '';
    RAISE NOTICE 'READY TO TEST: 25mx347@psgtech.ac.in';
    RAISE NOTICE '========================================';
END $$;
