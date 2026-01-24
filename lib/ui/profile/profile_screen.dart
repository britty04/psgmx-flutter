import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/app_user.dart';
import '../../core/theme/app_spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48, 
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0] : '?', 
                    style: TextStyle(fontSize: 32, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(user.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
                const SizedBox(height: AppSpacing.sm),
                Chip(
                  label: Text(provider.isActualPlacementRep ? "Placement Rep" : "Student"),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                )
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          if (provider.isActualPlacementRep) ...[
             Text("Simulation Mode", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
             const SizedBox(height: AppSpacing.sm),
             Card(
               child: Column(
                 children: [
                   SwitchListTile(
                     title: const Text("Simulate Student"),
                     subtitle: const Text("View app as access level: Student"),
                     secondary: const Icon(Icons.person_outline),
                     value: provider.simulatedRole == UserRole.student,
                     onChanged: (v) => provider.setSimulationRole(v ? UserRole.student : null),
                   ),
                   const Divider(height: 1),
                   SwitchListTile(
                     title: const Text("Simulate Team Leader"),
                     subtitle: const Text("View app as access level: Leader"),
                     secondary: const Icon(Icons.badge_outlined),
                     value: provider.simulatedRole == UserRole.teamLeader,
                     onChanged: (v) => provider.setSimulationRole(v ? UserRole.teamLeader : null),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: AppSpacing.lg),
          ],

          Text("Account", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                   leading: const Icon(Icons.settings_outlined),
                   title: const Text("App Settings"),
                   trailing: const Icon(Icons.chevron_right),
                   onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                   leading: const Icon(Icons.logout, color: Colors.red),
                   title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
                   onTap: () => _confirmSignOut(context, provider),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              "Version 1.0.0", 
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              provider.signOut();
            }, 
            child: const Text("Sign Out")
          ),
        ],
      ),
    );
  }
}
