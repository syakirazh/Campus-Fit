import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/badge.dart';
import '../../state/activity_state.dart';
import '../../state/content_state.dart';
import '../../theme/app_colors.dart';

/// Screen 22 — achievements: a streak summary and a grid of earned and locked
/// badges. Earned state is derived from the user's lifetime stats.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activity = context.watch<ActivityState>();
    final content = context.watch<ContentState>();

    final joinedCount = content.events
        .where((e) => content.isRegistered(e.id))
        .length;

    final earned = <String>{
      if (activity.lifetimeSteps >= 1000) 'first_steps',
      if (activity.streak >= 1) 'goal_getter',
      if (activity.streak >= 7) 'week_warrior',
      if (activity.workoutsCompleted >= 5) 'dorm_athlete',
      if (joinedCount >= 1) 'team_player',
      if (activity.lifetimeSteps >= 8000) 'explorer',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: AppColors.accentCoral.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 40, color: AppColors.accentCoral),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${activity.streak} day streak',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            '${earned.length} of ${AchievementBadge.catalogue.length} badges earned',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Badges',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AchievementBadge.catalogue.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) {
                final badge = AchievementBadge.catalogue[i];
                return _BadgeTile(
                  badge: badge,
                  earned: earned.contains(badge.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earned});
  final AchievementBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earned
            ? AppColors.goldBadge.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: earned
              ? AppColors.goldBadge.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            earned ? badge.icon : Icons.lock_outline,
            size: 40,
            color: earned
                ? AppColors.goldBadge
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(badge.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(badge.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
