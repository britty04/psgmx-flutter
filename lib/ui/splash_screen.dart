import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Failsafe timer
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    // Start a failsafe timer
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() => _showRetry = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'PSG MCA Placement Prep',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Initializing...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (_showRetry) ...[
               const SizedBox(height: 48),
               FilledButton.icon(
                 onPressed: () {
                    // Force refresh or navigation
                    final provider = context.read<UserProvider>();
                    if (provider.initComplete) {
                       // If provider says complete but we are here, strict navigate
                       if (provider.currentUser != null) {
                          context.go('/');
                       } else {
                          context.go('/login');
                       }
                    } else {
                       // Retry init
                       provider.retryInit();
                    }
                 },
                 icon: const Icon(Icons.refresh),
                 label: const Text("Stuck? Tap to Refresh"),
                 style: FilledButton.styleFrom(
                   backgroundColor: Colors.amber.shade700,
                   foregroundColor: Colors.white,
                 ),
               )
            ]
          ],
        ),
      ),
    );
  }
}
