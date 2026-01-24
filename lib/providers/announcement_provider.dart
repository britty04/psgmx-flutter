import 'package:flutter/foundation.dart';
import '../models/announcement.dart';
import '../services/supabase_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;
  
  List<Announcement> _announcements = [];
  List<Announcement> get announcements => _announcements;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AnnouncementProvider(this._supabaseService);

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabaseService.client
          .from('announcements')
          .select()
          .order('is_priority', ascending: false)
          .order('created_at', ascending: false);

      _announcements = (response as List)
          .map((e) => Announcement.fromMap(e))
          .where((a) => a.expiryDate == null || a.expiryDate!.isAfter(DateTime.now()))
          .toList();
          
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAnnouncement(String title, String message, bool isPriority, DateTime? expiry) async {
    final user = _supabaseService.client.auth.currentUser;
    if (user == null) return;

    try {
      await _supabaseService.client.from('announcements').insert({
        'title': title,
        'message': message,
        'is_priority': isPriority,
        'expiry_date': expiry?.toIso8601String(),
        'created_by': user.id,
      });
      
      // Refresh list
      await fetchAnnouncements();
    } catch (e) {
      debugPrint('Error creating announcement: $e');
      rethrow;
    }
  }
}
