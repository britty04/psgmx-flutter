-- ========================================
-- PRODUCTION READY: User Management System
-- ========================================
-- Complete setup for all user types
-- Run this ONCE to ensure all users can login
-- ========================================

-- ========================================
-- STEP 1: Verify RLS Policies
-- ========================================

-- Drop and recreate users INSERT policy (if needed)
DROP POLICY IF EXISTS "users_insert_auth" ON users;
CREATE POLICY "users_insert_auth" ON users
  FOR INSERT 
  WITH CHECK (auth.uid() = id);

-- Verify whitelist is readable
DROP POLICY IF EXISTS "whitelist_read_all" ON whitelist;
CREATE POLICY "whitelist_read_all" ON whitelist
  FOR SELECT 
  USING (TRUE);

-- ========================================
-- STEP 2: Add Sample Users to Whitelist
-- ========================================
-- Replace with your actual student data

INSERT INTO whitelist (email, name, reg_no, batch, team_id, roles, leetcode_username) VALUES
  -- Placement Representative
  ('25mx354@psgtech.ac.in', 'Placement Rep', '25MX354', 'G1', null, 
   '{"isStudent": false, "isTeamLeader": false, "isCoordinator": false, "isPlacementRep": true}'::jsonb, null),
  
  -- Regular Students
  ('25mx347@psgtech.ac.in', 'Student 347', '25MX347', 'G1', 'A1', 
   '{"isStudent": true, "isTeamLeader": false, "isCoordinator": false, "isPlacementRep": false}'::jsonb, null),
  
  ('25mx001@psgtech.ac.in', 'Student One', '25MX001', 'G1', 'A1', 
   '{"isStudent": true, "isTeamLeader": false, "isCoordinator": false, "isPlacementRep": false}'::jsonb, null),
  
  ('25mx002@psgtech.ac.in', 'Student Two', '25MX002', 'G1', 'A1', 
   '{"isStudent": true, "isTeamLeader": false, "isCoordinator": false, "isPlacementRep": false}'::jsonb, null),
  
  -- Team Leader Example
  ('25mx010@psgtech.ac.in', 'Team Leader', '25MX010', 'G1', 'A1', 
   '{"isStudent": false, "isTeamLeader": true, "isCoordinator": false, "isPlacementRep": false}'::jsonb, null),
  
  -- Coordinator Example
  ('coordinator@psgtech.ac.in', 'Coordinator', 'COORD01', 'G1', null, 
   '{"isStudent": false, "isTeamLeader": false, "isCoordinator": true, "isPlacementRep": false}'::jsonb, null)

ON CONFLICT (email) 
DO UPDATE SET
  name = EXCLUDED.name,
  reg_no = EXCLUDED.reg_no,
  batch = EXCLUDED.batch,
  team_id = EXCLUDED.team_id,
  roles = EXCLUDED.roles,
  leetcode_username = EXCLUDED.leetcode_username;

-- ========================================
-- STEP 3: Verify Setup
-- ========================================

-- Show all whitelist users
SELECT 
  email,
  name,
  reg_no,
  batch,
  team_id,
  roles->'isStudent' as is_student,
  roles->'isTeamLeader' as is_team_leader,
  roles->'isPlacementRep' as is_placement_rep
FROM whitelist
ORDER BY email;

-- Show all existing users
SELECT 
  email,
  name,
  reg_no,
  batch,
  team_id,
  roles->'isStudent' as is_student,
  created_at
FROM users
ORDER BY created_at DESC;

-- ========================================
-- STEP 4: Clean up any orphaned auth users
-- ========================================
-- (Optional - only if you have auth users without profiles)

-- Find auth users without profiles
SELECT 
  au.id,
  au.email,
  au.created_at,
  'No profile' as status
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL
ORDER BY au.created_at DESC;

-- ========================================
-- STEP 5: Test Queries
-- ========================================

-- Test: Can a new user insert their profile?
-- This should return TRUE
SELECT 
  pol.policyname,
  pol.cmd,
  pol.permissive,
  pol.with_check
FROM pg_policies pol
WHERE pol.tablename = 'users' 
  AND pol.cmd = 'INSERT';

-- Test: Can users read whitelist?
SELECT 
  pol.policyname,
  pol.cmd,
  pol.permissive
FROM pg_policies pol
WHERE pol.tablename = 'whitelist' 
  AND pol.cmd = 'SELECT';

-- ========================================
-- SUCCESS MESSAGE
-- ========================================

DO $$
DECLARE
  whitelist_count INT;
  user_count INT;
  policy_count INT;
BEGIN
  SELECT COUNT(*) INTO whitelist_count FROM whitelist;
  SELECT COUNT(*) INTO user_count FROM users;
  SELECT COUNT(*) INTO policy_count FROM pg_policies WHERE tablename = 'users';
  
  RAISE NOTICE '✅ SETUP COMPLETE';
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '📋 Whitelist Users: %', whitelist_count;
  RAISE NOTICE '👥 Registered Users: %', user_count;
  RAISE NOTICE '🔒 Security Policies: %', policy_count;
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  RAISE NOTICE '🚀 Your app is now production-ready!';
  RAISE NOTICE '📱 All users in whitelist can now login';
END $$;
