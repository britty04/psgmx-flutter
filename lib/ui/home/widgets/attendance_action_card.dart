import 'package:flutter/material.dart';
import '../../widgets/premium_card.dart';
import '../../../../core/theme/app_dimens.dart';

class AttendanceActionCard extends StatelessWidget {
  final VoidCallback onTap;

  const AttendanceActionCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mark Team Attendance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Action required for today',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                     color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
