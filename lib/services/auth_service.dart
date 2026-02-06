import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/app_user.dart';

/// AuthService: Secure OTP-based authentication using Supabase Auth
///
/// FLOW:
/// 1. User enters email (must be @psgtech.ac.in)
/// 2. System checks if email in whitelist
/// 3. OTP sent to email via Supabase
/// 4. User enters OTP -> Session created
/// 5. If new user, profile created from whitelist automatically
class AuthService {
  final SupabaseService _supabaseService;

  AuthService(this._supabaseService);

  /// Get current authenticated user
  User? get currentUser => _supabaseService.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current session
  Session? get currentSession => _supabaseService.auth.currentSession;

  /// STEP 1: VALIDATE EMAIL & SEND OTP
  Future<bool> sendOtpToEmail(String email) async {
    try {
      // 1. Validate domain
      if (!email.endsWith('@psgtech.ac.in')) {
        throw Exception('Only @psgtech.ac.in emails are allowed.');
      }

      email = email.trim().toLowerCase();
      debugPrint('[AuthService] Sending OTP to: $email');

      // 2. Check Whitelist
      final whitelistData = await _supabaseService
          .from('whitelist')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (whitelistData == null) {
        throw Exception('Email not authorized. Please contact administrator.');
      }

      // 3. Send OTP Token
      // Note: Users MUST exist in auth.users (created via SQL script with matching UUIDs)
      await _supabaseService.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false, // Users pre-exist with matching UUIDs
      );

      debugPrint('[AuthService] ✅ OTP sent to $email');
      return true;

    } on AuthException catch (e) {
      debugPrint('[AuthService] Auth Error: ${e.message}');
      
      // If user doesn't exist, provide clear error
      if (e.message.contains('Database error finding user') || 
          e.message.contains('User not found')) {
        throw 'User not found. Please contact administrator to add your account.';
      }
      
      if (e.message.contains('rate limit')) {
        throw 'Too many requests. Please wait a moment.';
      }
      throw e.message;
    } catch (e) {
      debugPrint('[AuthService] Error: $e');
      throw e.toString();
    }
  }

  /// STEP 2: VERIFY OTP (Magic Link Token)
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      email = email.trim().toLowerCase();
      
      if (otp.length != 6) {
        throw 'OTP must be 6 digits';
      }

      debugPrint('[AuthService] Verifying OTP for $email');

      // Verify OTP with Supabase (using magic link token)
      final response = await _supabaseService.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.session == null) {
        throw 'Verification failed. Please try again.';
      }

      final user = response.user;
      if (user == null) {
        throw 'User data not available.';
      }

      debugPrint('[AuthService] ✅ OTP verified successfully');
      debugPrint('[AuthService] User authenticated: ${user.email}');
      debugPrint('[AuthService] User ID: ${user.id}');

      // Profile should already exist with matching UUID
      // No need to create or check - UserProvider will fetch it
      debugPrint('[AuthService] ✅ Login complete for: $email');

    } on AuthException catch (e) {
      debugPrint('[AuthService] Auth error: ${e.message}');
      if (e.message.contains('Invalid') || e.message.contains('expired')) {
        throw 'Invalid or expired OTP. Please request a new one.';
      }
      throw e.message;
    } catch (e) {
      debugPrint('[AuthService] Unexpected error: $e');
      throw e.toString();
    }
  }

  /// Fetch user profile
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      debugPrint('[AuthService] Fetching profile for user ID: $userId');
      
      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('[AuthService] ❌ No profile found for user ID: $userId');
        return null;
      }
      
      debugPrint('[AuthService] ✅ Profile found: ${response['email']} - ${response['name']}');
      return AppUser.fromJson(response);
    } catch (e) {
      debugPrint('[AuthService] ❌ Error fetching profile: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _supabaseService.auth.signOut();
  }
}
