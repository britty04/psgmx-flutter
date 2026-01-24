import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/supabase_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;
  
  List<AppUser> _teamMembers = [];
  List<AppUser> get teamMembers => _teamMembers;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _hasSubmittedToday = false;
  bool get hasSubmittedToday => _hasSubmittedToday;

  AttendanceProvider(this._supabaseService);

  Future<void> loadTeamMembers(String teamId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _supabaseService.client
          .from('users')
          .select()
          .eq('team_id', teamId)
          .order('reg_no');
          
      _teamMembers = (response as List).map((e) => AppUser.fromMap(e)).toList();
      
      // Check if already submitted today
      await _checkSubmissionStatus(teamId);
      
    } catch (e) {
      debugPrint('Error loading team: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkSubmissionStatus(String teamId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final count = await _supabaseService.client
        .from('attendance')
        .count()
        .eq('team_id', teamId)
        .eq('date', today);
        
    _hasSubmittedToday = count > 0;
  }

  Future<void> submitAttendance(String teamId, Map<String, String> statusMap) async {
    if (_hasSubmittedToday) throw Exception("Already submitted for today");
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    final user = _supabaseService.client.auth.currentUser;
    
    final List<Map<String, dynamic>> rows = [];
    statusMap.forEach((studentId, status) {
      rows.add({
        'date': today,
        'student_id': studentId,
        'team_id': teamId,
        'status': status,
        'marked_by': user!.id,
      });
    });

    if (rows.isNotEmpty) {
      await _supabaseService.client.from('attendance').insert(rows);
      _hasSubmittedToday = true;
      notifyListeners();
    }
  }
}
