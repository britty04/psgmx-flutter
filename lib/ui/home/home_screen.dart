import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/supabase_db_service.dart';
import '../../services/quote_service.dart';
import '../../core/theme/app_spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final dbService = Provider.of<SupabaseDbService>(context, listen: false);
    final quoteService = Provider.of<QuoteService>(context, listen: false);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PSG MCA Prep"),
            Text(
              "Tech Placement 2026",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          _RoleBadge(userProvider: userProvider),
          const SizedBox(width: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user.name.isNotEmpty ? user.name[0] : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text("Welcome back,", style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),
                _QuoteCard(service: quoteService),
                const SizedBox(height: AppSpacing.sectionSpacing),
                
                if (userProvider.isCoordinator || (userProvider.isActualPlacementRep && !userProvider.isSimulating))
                  _AdminDashboard(db: dbService)
                else
                  _StudentDashboard(db: dbService, provider: userProvider),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserProvider userProvider;
  const _RoleBadge({required this.userProvider});

  @override
  Widget build(BuildContext context) {
    Color badgeColor = Colors.grey;
    String roleLabel = "Guest";

    // Determine Role Label & Color
    if (userProvider.isPlacementRep) {
      badgeColor = Colors.purple;
      roleLabel = "Rep";
    } else if (userProvider.isCoordinator) {
      badgeColor = Colors.orange;
      roleLabel = "Coord";
    } else if (userProvider.isTeamLeader) {
      badgeColor = Colors.blue;
      roleLabel = "Lead";
    } else {
      badgeColor = Colors.green;
      roleLabel = "Student";
    }

    if (userProvider.isSimulating) {
      roleLabel = "SIM: $roleLabel";
      badgeColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        roleLabel.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final QuoteService service;
  const _QuoteCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: service.getDailyQuote(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final quote = data?['text'] ?? "Consistent effort beats bursts of intensity.";
        final author = data?['author'] ?? "PSG Tech";

        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8), size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "Daily Motivation",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '"$quote"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "- $author",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  final SupabaseDbService db;
  const _AdminDashboard({required this.db});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: db.getPlacementStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: LinearProgressIndicator());
        
        final data = snapshot.data!;
        final total = data['total_students'] as int;
        final present = data['today_present'] as int;
        final percent = total > 0 ? (present / total) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Overview", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _StatCard(label: "Students", value: "$total", icon: Icons.groups_outlined)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(label: "Present", value: "$present", icon: Icons.check_circle_outline)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Attendance Rate"),
                        Text(
                          "${(percent * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: percent,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _StudentDashboard extends StatelessWidget {
  final SupabaseDbService db;
  final UserProvider provider;
  const _StudentDashboard({required this.db, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
         const SizedBox(height: AppSpacing.md),
         ListTile(
           tileColor: Theme.of(context).colorScheme.surfaceContainer,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           leading: const Icon(Icons.task_alt),
           title: const Text("View Today's Tasks"),
           subtitle: const Text("Check pending submissions"),
           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
           onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Switch to Tasks Tab")));
           },
         ),
         const SizedBox(height: AppSpacing.sm),
         ListTile(
           tileColor: Theme.of(context).colorScheme.surfaceContainer,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           leading: const Icon(Icons.calendar_today),
           title: const Text("Check Attendance"),
           subtitle: Text(provider.isTeamLeader ? "Mark Team Attendance" : "View History"),
           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
           onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Switch to Attendance Tab")));
           },
         ),
      ],
    );
  }
}
