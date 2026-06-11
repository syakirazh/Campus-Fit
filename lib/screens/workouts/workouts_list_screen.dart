import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../state/content_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/workout_card.dart';
import 'create_workout_screen.dart';
import 'workout_detail_screen.dart';

/// Screen 12 — workouts list with a featured "today's pick" and a list of
/// short routines.
class WorkoutsListScreen extends StatelessWidget {
  const WorkoutsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: SafeArea(
        child: _body(context, content),
      ),
      // Signed-in students can build and publish their own routines.
      floatingActionButton: content.canCreateWorkouts
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New workout'),
            )
          : null,
    );
  }

  Widget _body(BuildContext context, ContentState content) {
    if (content.loading && content.workouts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (content.workouts.isEmpty) {
      return _ErrorRetry(
        message: content.error ?? 'No workouts found.',
        onRetry: () => content.load(force: true),
      );
    }
    final featured = content.featuredWorkout!;
    final rest = content.workouts.where((w) => w.id != featured.id).toList();

    return RefreshIndicator(
      onRefresh: () => content.load(force: true),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _FeaturedWorkout(workout: featured),
          const SizedBox(height: 24),
          const SectionHeader(title: 'All routines'),
          const SizedBox(height: 12),
          for (final w in rest) ...[
            WorkoutCard(
              workout: w,
              onTap: () => _open(context, w),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _open(BuildContext context, Workout w) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workoutId: w.id)),
    );
  }
}

class _FeaturedWorkout extends StatelessWidget {
  const _FeaturedWorkout({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workoutId: workout.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TODAY’S PICK',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      letterSpacing: 1.2)),
              const SizedBox(height: 6),
              Text(workout.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                '${workout.totalMinutes} min · ${workout.difficultyLabel} · '
                '${workout.exercises.length} exercises',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.colorScheme.onPrimary.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
