-- ========================================
-- SIMPLE FIX: Mark Existing Auth Users as Confirmed
-- ========================================
-- This ensures existing auth users can use OTP login
-- ========================================

-- Update any existing auth users to mark email as confirmed
UPDATE auth.users
SET 
    email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
    updated_at = NOW(),
    confirmation_sent_at = NULL,
    confirmation_token = ''
WHERE email LIKE '%@psgtech.ac.in'
  AND (email_confirmed_at IS NULL OR confirmation_token IS NOT NULL);

-- Sync user profiles from whitelist for any existing auth users
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
    SELECT 1 FROM public.users pu WHERE pu.id = au.id
)
ON CONFLICT (id) DO NOTHING;

-- Verification
DO $$
DECLARE
    auth_count INT;
    confirmed_count INT;
    users_count INT;
    whitelist_count INT;
BEGIN
    SELECT COUNT(*) INTO auth_count FROM auth.users 
    WHERE email LIKE '%@psgtech.ac.in';
    
    SELECT COUNT(*) INTO confirmed_count FROM auth.users 
    WHERE email LIKE '%@psgtech.ac.in' AND email_confirmed_at IS NOT NULL;
    
    SELECT COUNT(*) INTO users_count FROM public.users 
    WHERE email LIKE '%@psgtech.ac.in';
    
    SELECT COUNT(*) INTO whitelist_count FROM public.whitelist;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ EXISTING AUTH USERS UPDATED';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Whitelist entries: %', whitelist_count;
    RAISE NOTICE 'Auth users (existing): %', auth_count;
    RAISE NOTICE 'Auth users confirmed: %', confirmed_count;
    RAISE NOTICE 'User profiles synced: %', users_count;
    RAISE NOTICE '';
    IF auth_count = 0 THEN
        RAISE NOTICE '⚠️  NO AUTH USERS FOUND';
        RAISE NOTICE 'Users need to request OTP once to create auth entry';
        RAISE NOTICE 'First OTP will be confirmation link (one time only)';
        RAISE NOTICE 'After that, all OTPs will be 6-digit codes';
    ELSE
        RAISE NOTICE '✅ READY FOR OTP LOGIN';
        RAISE NOTICE 'Existing users will receive 6-digit OTP codes';
    END IF;
    RAISE NOTICE '========================================';
END $$;
