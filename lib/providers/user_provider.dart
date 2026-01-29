import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService;
  AppUser? _currentUser;
  bool _isLoading = true;
  bool _initComplete = false;

  // Simulation Mode
  UserRole? _simulatedRole;

  UserProvider({required AuthService authService})
      : _authService = authService {
    _init();
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get initComplete => _initComplete;

  bool get isSimulating => _simulatedRole != null;
  UserRole? get simulatedRole => _simulatedRole;

  AuthService get authService => _authService;

  bool get isStudent => _simulatedRole != null
      ? _simulatedRole == UserRole.student
      : (_currentUser?.isStudent ?? false);

  bool get isTeamLeader => _simulatedRole != null
      ? _simulatedRole == UserRole.teamLeader
      : (_currentUser?.isTeamLeader ?? false);

  bool get isCoordinator => _simulatedRole != null
      ? _simulatedRole == UserRole.coordinator
      : (_currentUser?.isCoordinator ?? false);

  bool get isPlacementRep => _simulatedRole != null
      ? _simulatedRole == UserRole.placementRep
      : (_currentUser?.isPlacementRep ?? false);

  bool get hasActualAdminAccess => _currentUser?.hasAdminAccess ?? false;
  bool get isActualPlacementRep => _currentUser?.isPlacementRep ?? false;

  void setSimulationRole(UserRole? role) {
    if (!isActualPlacementRep) return;
    _simulatedRole = role;
    notifyListeners();
  }

  void retryInit() {
    _init();
  }

  void _init() {
    debugPrint('[UserProvider] Initializing...');
    _checkAuthStateOnce();
  }

  Future<void> _checkAuthStateOnce() async {
    try {
      final supabaseUser = _authService.currentUser;
      if (supabaseUser != null) {
        _currentUser = await _authService.getUserProfile(supabaseUser.id);
        if (_currentUser != null) {
          _scheduleBirthdayNotificationIfNeeded();
        }
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      _initComplete = true;
      notifyListeners();
      _listenToAuthStateChanges();
    }
  }

  void _listenToAuthStateChanges() {
    _authService.authStateChanges.listen(
      (AuthState authState) async {
        final supabaseUser = authState.session?.user;
        if (supabaseUser != null) {
          try {
            _currentUser = await _authService.getUserProfile(supabaseUser.id);
            if (_currentUser != null) {
              _scheduleBirthdayNotificationIfNeeded();
            }
          } catch (e) {
            _currentUser = null;
          }
        } else {
          _currentUser = null;
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[UserProvider] Auth stream error: $e');
      },
    );
  }

  /// Request OTP
  Future<bool> requestOtp({required String email}) async {
    try {
      final success = await _authService.sendOtpToEmail(email);
      return success;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _authService.verifyOtp(email: email, otp: otp);
      // Auth state listener will pick up the new session and load profile
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDob(DateTime newDob) async {
    if (_currentUser == null) return;
    try {
      final dobStr = newDob.toIso8601String().split('T')[0];
      await Supabase.instance.client
          .from('users')
          .update({'dob': dobStr}).eq('id', _currentUser!.uid);

      _currentUser = _currentUser!.copyWith(dob: newDob);
      notifyListeners();
      _scheduleBirthdayNotificationIfNeeded();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBirthdayNotification(bool enabled) async {
    if (_currentUser == null) return;
    try {
      await Supabase.instance.client
          .from('users')
          .update({'birthday_notifications_enabled': enabled}).eq(
              'id', _currentUser!.uid);

      _currentUser =
          _currentUser!.copyWith(birthdayNotificationsEnabled: enabled);
      notifyListeners();
      _scheduleBirthdayNotificationIfNeeded();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLeetCodeUsername(String username) async {
    if (_currentUser == null) return;
    try {
      await Supabase.instance.client
          .from('users')
          .update({'leetcode_username': username}).eq('id', _currentUser!.uid);

      _currentUser = _currentUser!.copyWith(leetcodeUsername: username);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLeetCodeNotification(bool enabled) async {
    if (_currentUser == null) return;
    try {
      await Supabase.instance.client
          .from('users')
          .update({'leetcode_notifications_enabled': enabled}).eq(
              'id', _currentUser!.uid);

      _currentUser =
          _currentUser!.copyWith(leetcodeNotificationsEnabled: enabled);
      notifyListeners();

      if (enabled) {
        await NotificationService().scheduleLeetCodeReminders();
      } else {
        await NotificationService().cancelLeetCodeReminders();
      }
    } catch (e) {
      rethrow;
    }
  }

  void _scheduleBirthdayNotificationIfNeeded() {
    if (_currentUser == null) return;
    try {
      if (_currentUser!.dob != null) {
        NotificationService().scheduleBirthdayNotification(
          dob: _currentUser!.dob!,
          userName: _currentUser!.name,
          enabled: _currentUser!.birthdayNotificationsEnabled,
        );
      }
    } catch (e) {
      debugPrint('[UserProvider] Error scheduling birthday notification: $e');
    }
  }
}
