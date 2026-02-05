-- ========================================
-- CHECK SUPABASE EMAIL CONFIGURATION
-- ========================================
-- Run this in Supabase SQL Editor to see auth config
-- ========================================

-- Check if email confirmations are required
SELECT 
    'Email Confirmation Setting' as check_type,
    setting_value
FROM auth.config
WHERE setting_name = 'MAILER_AUTOCONFIRM'
UNION ALL
SELECT 
    'Secure Email Change' as check_type,
    setting_value
FROM auth.config  
WHERE setting_name = 'MAILER_SECURE_EMAIL_CHANGE_ENABLED';

-- Check recent OTP attempts
SELECT 
    id,
    email,
    created_at,
    confirmation_sent_at,
    confirmed_at,
    email_confirmed_at
FROM auth.users
WHERE email IN ('25mx336@psgtech.ac.in', '25mx347@psgtech.ac.in', '25mx354@psgtech.ac.in')
ORDER BY created_at DESC;

-- Check if whitelist has the users
SELECT 
    email,
    name,
    reg_no,
    batch
FROM public.whitelist
WHERE email IN ('25mx336@psgtech.ac.in', '25mx347@psgtech.ac.in', '25mx354@psgtech.ac.in')
ORDER BY email;

-- ========================================
-- VERIFICATION
-- ========================================
DO $$
DECLARE
    whitelist_count INT;
BEGIN
    SELECT COUNT(*) INTO whitelist_count 
    FROM public.whitelist 
    WHERE email IN ('25mx336@psgtech.ac.in', '25mx347@psgtech.ac.in', '25mx354@psgtech.ac.in');
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '📧 EMAIL CONFIGURATION CHECK';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Users in whitelist: %', whitelist_count;
    RAISE NOTICE '';
    RAISE NOTICE 'If email_confirmed_at is NULL for a user,';
    RAISE NOTICE 'they need to verify their email with OTP.';
    RAISE NOTICE '';
    RAISE NOTICE 'Check the output above for:';
    RAISE NOTICE '1. Email confirmation settings';
    RAISE NOTICE '2. User auth status';
    RAISE NOTICE '3. Whitelist entries';
    RAISE NOTICE '========================================';
END $$;
