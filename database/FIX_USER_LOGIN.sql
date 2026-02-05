-- ========================================
-- QUICK FIX: Add Missing Users to Whitelist
-- ========================================
-- Run this in Supabase SQL Editor to add users
-- that are having login issues
-- ========================================

-- Check if user exists in whitelist
SELECT 'Whitelist Check' as status, * FROM whitelist WHERE email = '25mx347@psgtech.ac.in';

-- If not found, add them:
INSERT INTO whitelist (email, name, reg_no, batch, team_id, roles)
VALUES (
  '25mx347@psgtech.ac.in',
  'Student Name',  -- Change this to actual name
  '25MX347',
  'G1',  -- Change to G1 or G2
  null,  -- Optional: team ID like 'A1', 'A2', etc.
  '{"isStudent": true, "isTeamLeader": false, "isCoordinator": false, "isPlacementRep": false}'::jsonb
)
ON CONFLICT (email) DO NOTHING;

-- Verify RLS policies are correct
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'users'
ORDER BY cmd, policyname;

-- Check if there's already a user record (might be partial)
SELECT 'User Check' as status, * FROM users WHERE email = '25mx347@psgtech.ac.in';

-- If user exists but is incomplete, update it:
-- UPDATE users 
-- SET 
--   name = 'Student Name',
--   reg_no = '25MX347',
--   batch = 'G1'
-- WHERE email = '25mx347@psgtech.ac.in';

-- Add multiple users at once (if needed)
-- INSERT INTO whitelist (email, name, reg_no, batch, roles) VALUES
-- ('student1@psgtech.ac.in', 'Student One', '25MX001', 'G1', '{"isStudent": true}'::jsonb),
-- ('student2@psgtech.ac.in', 'Student Two', '25MX002', 'G1', '{"isStudent": true}'::jsonb),
-- ('student3@psgtech.ac.in', 'Student Three', '25MX003', 'G2', '{"isStudent": true}'::jsonb)
-- ON CONFLICT (email) DO NOTHING;

-- Grant proper permissions (run if policies are missing)
-- DROP POLICY IF EXISTS "users_insert_auth" ON users;
-- CREATE POLICY "users_insert_auth" ON users
--   FOR INSERT 
--   WITH CHECK (auth.uid() = id);

-- DROP POLICY IF EXISTS "whitelist_read_all" ON whitelist;
-- CREATE POLICY "whitelist_read_all" ON whitelist
--   FOR SELECT 
--   USING (TRUE);

-- Verify everything is set up correctly
SELECT 
  'Setup Complete' as status,
  (SELECT count(*) FROM whitelist) as whitelist_count,
  (SELECT count(*) FROM users) as users_count,
  (SELECT count(*) FROM pg_policies WHERE tablename = 'users') as user_policies;
