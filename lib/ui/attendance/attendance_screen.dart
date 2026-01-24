import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../services/supabase_db_service.dart';
import '../../models/app_user.dart';
import '../../core/theme/app_spacing.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isTeamLeader) {
       return const _TeamAttendanceView();
    }
    return const _StudentAttendanceView();
  }
}

// ==========================================
// STUDENT VIEW
// ==========================================

class _StudentAttendanceView extends StatelessWidget {
  const _StudentAttendanceView();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;
    final db = Provider.of<SupabaseDbService>(context, listen: false);

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text("My Attendance")),
      body: StreamBuilder<List<AttendanceRecord>>(
        stream: db.getStudentAttendance(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
             return const _EmptyState(message: "No attendance records found");
          }

          return ListView.separated(
             padding: const EdgeInsets.all(AppSpacing.screenPadding),
             itemCount: records.length,
             separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
             itemBuilder: (context, index) {
                final record = records[index];
                final dateStr = record.date is DateTime 
                    ? DateFormat('MMM dd, yyyy').format(record.date as DateTime) 
                    : record.date.toString();
                
                return Card(
                  child: ListTile(
                    leading: _StatusIcon(isPresent: record.isPresent),
                    title: Text(dateStr, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text("Recorded: ${DateFormat('hh:mm a').format(record.timestamp)}"),
                    trailing: _StatusChip(isPresent: record.isPresent),
                  ),
                );
             }
          );
        }
      )
    );
  }
}

// ==========================================
// TEAM LEADER VIEW
// ==========================================

class _TeamAttendanceView extends StatefulWidget {
  const _TeamAttendanceView();

  @override
  State<_TeamAttendanceView> createState() => _TeamAttendanceViewState();
}

class _TeamAttendanceViewState extends State<_TeamAttendanceView> {
  final Set<String> _absentees = {}; 
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final db = Provider.of<SupabaseDbService>(context, listen: false);
    
    // Fallback for simulation
    final String teamId = user?.teamId ?? (userProvider.isSimulating ? 'TEAM-SIM' : 'UNKNOWN');
    final todayStr = DateFormat('EEEE, MMM d').format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Team $teamId", style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(todayStr, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                   children: [
                      Icon(Icons.info_outline, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Text("Uncheck students who are ABSENT today.", style: Theme.of(context).textTheme.bodySmall),
                   ],
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AppUser>>(
              future: db.getTeamMembers(teamId),
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                 if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                 
                 final members = snapshot.data ?? [];
                 
                 if (members.isEmpty) {
                   return const _EmptyState(message: "No members assigned to this team.");
                 }
      
                 return ListView.separated(
                   padding: const EdgeInsets.all(AppSpacing.screenPadding),
                   itemCount: members.length,
                   separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                   itemBuilder: (context, index) {
                      final member = members[index]; 
                      final isPresent = !_absentees.contains(member.uid);
                      
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        child: CheckboxListTile(
                           contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                           activeColor: Colors.green,
                           value: isPresent, 
                           title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                           subtitle: Text(member.regNo),
                           secondary: CircleAvatar(
                             radius: 16,
                             backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                             child: Text(member.name.isNotEmpty ? member.name[0] : '?', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimaryContainer))
                           ),
                           onChanged: (val) {
                              setState(() {
                                 if (val == true) {
                                   _absentees.remove(member.uid);
                                 } else {
                                   _absentees.add(member.uid);
                                 }
                              });
                           },
                        ),
                      );
                   }
                 );
              }
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton.icon(
            onPressed: _isLoading ? null : () => _submit(db, teamId, user!.uid), 
            label: _isLoading ? const Text("Submitting...") : const Text("Submit Attendance"),
            icon: _isLoading ?              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
              : const Icon(Icons.check_circle_outline),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(SupabaseDbService db, String teamId, String uid) async {
      setState(() => _isLoading = true);
      try {
         final members = await db.getTeamMembers(teamId);
         final records = <AttendanceRecord>[];
         final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
         final now = DateTime.now();

         for (var m in members) {
             final isAbsent = _absentees.contains(m.uid);
             records.add(AttendanceRecord(
               id: '', 
               date: dateStr, // Pass String, not DateTime
               studentUid: m.uid, 
               regNo: m.regNo, 
               teamId: teamId, 
               isPresent: !isAbsent, 
               timestamp: now, 
               markedBy: uid
             ));
         }

         await db.submitTeamAttendance(teamId, dateStr, uid, records);
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attendance Submitted Successfully")));
         
      } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
         setState(() => _isLoading = false);
      }
  }
}

// ==========================================
// SHARED WIDGETS
// ==========================================

class _StatusIcon extends StatelessWidget {
  final bool isPresent;
  const _StatusIcon({required this.isPresent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isPresent ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPresent ? Icons.check : Icons.close, 
        color: isPresent ? Colors.green : Colors.red,
        size: 16
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isPresent;
  const _StatusChip({required this.isPresent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPresent ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isPresent ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        isPresent ? "PRESENT" : "ABSENT",
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.bold,
          color: isPresent ? Colors.green.shade700 : Colors.red.shade700
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(Icons.event_busy, size: 48, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
           const SizedBox(height: AppSpacing.md),
           Text(message, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }
}
