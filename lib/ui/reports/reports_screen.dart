import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/supabase_db_service.dart';
import '../../core/theme/app_spacing.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<SupabaseDbService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Reports & Analytics")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: db.getPlacementStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          
          final data = snapshot.data!;
          final total = data['total_students'] as int;
          final present = data['today_present'] as int;
          final percent = total > 0 ? (present / total) : 0.0;
          
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
               _SummaryCard(total: total, present: present, percent: percent),
               const SizedBox(height: AppSpacing.lg),
               Text("Data Export", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
               const SizedBox(height: AppSpacing.md),
               Card(
                 elevation: 0,
                 color: Theme.of(context).cardTheme.color,
                 child: Column(
                   children: [
                     _ActionListTile(
                       icon: Icons.table_chart_outlined,
                       title: "Attendance Report",
                       subtitle: "Download as .xlsx",
                       onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cloud Function required")));
                       },
                     ),
                     Divider(height: 1, indent: 56, color: Theme.of(context).dividerColor),
                     _ActionListTile(
                       icon: Icons.task_outlined,
                       title: "Task Submissions",
                       subtitle: "Download as .csv",
                       onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not implemented")));
                       },
                     ),
                   ],
                 ),
               )
            ],
          );
        }
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final int present;
  final double percent;

  const _SummaryCard({required this.total, required this.present, required this.percent});

  @override
  Widget build(BuildContext context) {
     return Card(
       color: Theme.of(context).colorScheme.primary,
       child: Padding(
         padding: const EdgeInsets.all(AppSpacing.lg),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Text("Today's Overview", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _Metric(label: "Total Students", value: total.toString()),
                   Container(height: 40, width: 1, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2)),
                   _Metric(label: "Present", value: present.toString()),
                   Container(height: 40, width: 1, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2)),
                   _Metric(label: "Rate", value: "${(percent * 100).toStringAsFixed(1)}%"),
                ],
              )
           ],
         ),
       ),
     );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
     return Column(
       children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7))),
       ],
     );
  }
}

class _ActionListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionListTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.download, size: 20, color: Theme.of(context).colorScheme.outline),
      onTap: onTap,
    );
  }
}
