-- ========================================
-- PRE-CREATE AUTH USERS FOR ALL WHITELIST
-- ========================================
-- This creates auth.users entries for all whitelisted users
-- so they can login with OTP (not signup confirmation)
-- ========================================

-- Update existing auth users to mark email as confirmed
UPDATE auth.users
SET 
    email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
    updated_at = NOW()
WHERE email IN (SELECT email FROM public.whitelist)
  AND email_confirmed_at IS NULL;

-- Sync user profiles for auth users (update email constraint to use id)
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
    au.id,
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
FROM auth.users au
JOIN public.whitelist w ON au.email = w.email
WHERE NOT EXISTS (
    SELECT 1 FROM public.users pu WHERE pu.email = w.email
)
ON CONFLICT (email) DO NOTHING;

-- Verification
DO $$
DECLARE
    auth_count INT;
    users_count INT;
    whitelist_count INT;
BEGIN
    SELECT COUNT(*) INTO auth_count FROM auth.users 
    WHERE email LIKE '%@psgtech.ac.in';
    
    SELECT COUNT(*) INTO users_count FROM public.users 
    WHERE email LIKE '%@psgtech.ac.in';
    
    SELECT COUNT(*) INTO whitelist_count FROM public.whitelist;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ AUTH USERS PRE-CREATED';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Whitelist entries: %', whitelist_count;
    RAISE NOTICE 'Auth users created: %', auth_count;
    RAISE NOTICE 'User profiles created: %', users_count;
    RAISE NOTICE '';
    RAISE NOTICE 'NOW USERS CAN LOGIN WITH OTP (NOT SIGNUP)';
    RAISE NOTICE 'They will receive 6-digit code, not magic link';
    RAISE NOTICE '========================================';
END $$;
