import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../state/content_state.dart';
import 'workout_player_screen.dart';

/// Screen 13 — workout detail listing exercises and durations, with a
/// "start workout" button.
class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workout = context.watch<ContentState>().workoutById(workoutId);

    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('Workout not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                _chip(theme, Icons.schedule, '${workout.totalMinutes} min'),
                const SizedBox(width: 8),
                _chip(theme, Icons.bar_chart, workout.difficultyLabel),
                const SizedBox(width: 8),
                _chip(theme, Icons.local_fire_department,
                    '${workout.estimatedCalories} kcal'),
              ],
            ),
            const SizedBox(height: 12),
            Text('Equipment: ${workout.equipment}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Text('Exercises',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            for (var i = 0; i < workout.exercises.length; i++)
              _ExerciseRow(index: i + 1, exercise: workout.exercises[i]),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _start(context, workout),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start workout'),
            ),
          ),
        ),
      ),
    );
  }

  void _start(BuildContext context, Workout workout) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkoutPlayerScreen(workout: workout)),
    );
  }

  Widget _chip(ThemeData theme, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.index, required this.exercise});
  final int index;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text('$index',
                    style: TextStyle(color: theme.colorScheme.primary)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    if (exercise.description.isNotEmpty)
                      Text(exercise.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Text('${exercise.durationSeconds}s',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
