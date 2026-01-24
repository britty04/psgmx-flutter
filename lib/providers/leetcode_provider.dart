import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/leetcode_stats.dart';
import '../services/supabase_service.dart';

class LeetCodeProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  final Map<String, LeetCodeStats> _statsCache = {};
  
  LeetCodeProvider(this._supabaseService);
  
  // Clean username helper
  String _cleanUsername(String username) {
    if (username.contains('/')) {
      final parts = username.split('/');
      return parts.lastWhere((element) => element.isNotEmpty);
    }
    return username.trim();
  }

  Future<LeetCodeStats?> fetchStats(String rawUsername) async {
    final username = _cleanUsername(rawUsername);
    if (username.isEmpty) return null;

    if (_statsCache.containsKey(username)) {
      // Return cached if fresh (e.g. < 1 hour) - ignoring freshness for simplicity now
      return _statsCache[username];
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // 1. Try to fetch from Supabase cache first
      final dbData = await _supabaseService.client
          .from('leetcode_stats')
          .select()
          .eq('username', username)
          .maybeSingle();
          
      if (dbData != null) {
        final stats = LeetCodeStats.fromMap(dbData);
        // If older than 24 hours, refresh
        if (DateTime.now().difference(stats.lastUpdated).inHours < 24) {
          _statsCache[username] = stats;
          _isLoading = false;
          notifyListeners();
          return stats;
        }
      }

      // 2. Fetch from LeetCode API
      final stats = await _fetchFromLeetCodeApi(username);
      
      // 3. Update Supabase
      if (stats != null) {
        await _supabaseService.client.from('leetcode_stats').upsert(stats.toMap());
        _statsCache[username] = stats;
      }
      
      _isLoading = false;
      notifyListeners();
      return stats;
      
    } catch (e) {
      debugPrint('Error fetching LeetCode stats: $e');
      _isLoading = false;
      notifyListeners();
      return _statsCache[username]; // Return stale if available
    }
  }

  Future<List<LeetCodeStats>> fetchLeaderboard({int limit = 3}) async {
    try {
      final response = await _supabaseService.client
          .from('leetcode_stats')
          .select()
          .order('total_solved', ascending: false)
          .limit(limit);
      
      return (response as List).map((e) => LeetCodeStats.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }

  Future<LeetCodeStats?> _fetchFromLeetCodeApi(String username) async {
    const String url = 'https://leetcode.com/graphql';
    const String query = r'''
      query getUserProfile($username: String!) {
        matchedUser(username: $username) {
          username
          submitStats: submitStatsGlobal {
            acSubmissionNum {
              difficulty
              count
              submissions
            }
          }
          profile {
            ranking
          }
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (compatible; PSGMX/1.0)',
        },
        body: jsonEncode({
          'query': query,
          'variables': {'username': username},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final matchedUser = data['data']?['matchedUser'];
        
        if (matchedUser == null) return null;
        
        final submitStats = matchedUser['submitStats']?['acSubmissionNum'] as List?;
        final profile = matchedUser['profile'];
        
        int easy = 0;
        int medium = 0;
        int hard = 0;
        int total = 0;
        
        if (submitStats != null) {
          for (var item in submitStats) {
            final count = item['count'] as int? ?? 0;
            final diff = item['difficulty'] as String?;
            if (diff == 'All') total = count;
            if (diff == 'Easy') easy = count;
            if (diff == 'Medium') medium = count;
            if (diff == 'Hard') hard = count;
          }
        }
        
        return LeetCodeStats(
          username: username,
          totalSolved: total,
          easySolved: easy,
          mediumSolved: medium,
          hardSolved: hard,
          ranking: profile?['ranking'] as int? ?? 0,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('LeetCode API Exception: $e');
    }
    return null;
  }
}
