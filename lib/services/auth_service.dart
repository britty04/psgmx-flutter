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

      // 3. Send OTP
      await _supabaseService.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );

      debugPrint('[AuthService] OTP sent successfully');
      return true;

    } on AuthException catch (e) {
      debugPrint('[AuthService] Auth Error: ${e.message}');
      if (e.message.contains('rate limit')) {
        throw 'Too many requests. Please wait a moment.';
      }
      throw e.message;
    } catch (e) {
      debugPrint('[AuthService] Error: $e');
      throw e.toString();
    }
  }

  /// STEP 2: VERIFY OTP
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

      final response = await _supabaseService.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.session == null) {
        throw 'Verification failed';
      }

      // Check if we need to create user profile
      final user = response.user;
      if (user != null) {
        await _ensureUserProfile(user.id, email);
      }

    } on AuthException catch (e) {
      debugPrint('[AuthService] Verify Error: ${e.message}');
      throw 'Invalid OTP or expired.';
    } catch (e) {
      throw e.toString();
    }
  }

  /// Internal: Create user profile if it doesn't exist
  Future<void> _ensureUserProfile(String userId, String email) async {
    try {
      final existingProfile = await getUserProfile(userId);
      if (existingProfile != null) return;

      debugPrint('[AuthService] Creating new user profile from whitelist...');
      
      // Fetch whitelist data
      final whitelistData = await _supabaseService.client
          .from('whitelist')
          .select()
          .eq('email', email)
          .single();

      // Create user
      final userData = {
        'id': userId,
        'email': email,
        'reg_no': whitelistData['reg_no'] ?? email.split('@')[0].toUpperCase(),
        'name': whitelistData['name'] ?? 'Student',
        'batch': whitelistData['batch'] ?? 'G1',
        'team_id': whitelistData['team_id'],
        'roles': whitelistData['roles'] ?? {
          'isStudent': true,
          'isTeamLeader': false,
          'isCoordinator': false,
          'isPlacementRep': false,
        },
        'dob': whitelistData['dob'],
        'leetcode_username': whitelistData['leetcode_username'],
        'birthday_notifications_enabled': true,
        'leetcode_notifications_enabled': true,
      };

      await _supabaseService.client.from('users').insert(userData);
      debugPrint('[AuthService] Profile created.');
    } catch (e) {
      debugPrint('[AuthService] Error ensuring profile: $e');
    }
  }

  /// Fetch user profile
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return AppUser.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _supabaseService.auth.signOut();
  }
}
