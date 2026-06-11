import 'package:flutter/material.dart';

import '../../models/workout.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_tile.dart';

/// Screen 15 — workout-complete summary: calories burned, time, exercises
/// done, and the updated streak.
class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({
    super.key,
    required this.workout,
    required this.elapsed,
    required this.newStreak,
  });

  final Workout workout;
  final Duration elapsed;
  final int newStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = (elapsed.inSeconds / 60).ceil().clamp(1, 999);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    size: 80, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text('Workout complete!',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Great work on ${workout.title}.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Icons.local_fire_department,
                      value: '${workout.estimatedCalories}',
                      label: 'kcal',
                      color: AppColors.accentCoral,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: Icons.timer_outlined,
                      value: '$minutes min',
                      label: 'Time',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: Icons.checklist,
                      value: '${workout.exercises.length}',
                      label: 'Exercises',
                      color: AppColors.distanceBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: AppColors.accentCoral.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: AppColors.accentCoral),
                      const SizedBox(width: 12),
                      Text('Streak: $newStreak ${newStreak == 1 ? "day" : "days"}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
