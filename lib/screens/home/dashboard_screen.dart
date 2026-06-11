import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../state/activity_state.dart';
import '../../state/content_state.dart';
import '../../state/session_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/event_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/step_ring.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/week_bar_chart.dart';
import '../events/event_detail_screen.dart';
import '../workouts/workout_detail_screen.dart';
import 'campus_zones_screen.dart';
import 'step_history_screen.dart';

/// Screen 9 — the home dashboard surfacing all key functionality in one view.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityState>();
    final content = context.watch<ContentState>();
    final session = context.watch<SessionState>();
    final name = session.session.displayName;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => content.load(force: true),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Greeting(name: name, streak: activity.streak),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => _open(context, const StepHistoryScreen()),
                  child: StepRing(
                    steps: activity.todaySteps,
                    goal: activity.stepGoal,
                  ),
                ),
              ),
              if (!activity.permissionGranted) _PermissionHint(activity: activity),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Icons.route,
                      value: '${activity.today.distanceKm.toStringAsFixed(2)} km',
                      label: 'Distance',
                      color: AppColors.distanceBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: Icons.local_fire_department,
                      value: '${activity.today.calories} kcal',
                      label: 'Calories',
                      color: AppColors.accentCoral,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: Icons.timer_outlined,
                      value: '${activity.today.activeMinutes} min',
                      label: 'Active',
                      color: AppColors.caloriesAmber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'This week',
                actionLabel: 'History',
                onAction: () => _open(context, const StepHistoryScreen()),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                  child: StepsBarChart(
                    data: activity.history(days: 7),
                    goal: activity.stepGoal,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Today’s workout',
                actionLabel: 'Zones',
                onAction: () => _open(context, const CampusZonesScreen()),
              ),
              const SizedBox(height: 12),
              _TodayWorkoutCard(workout: content.featuredWorkout),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Next event'),
              const SizedBox(height: 12),
              if (content.nextEvent != null)
                EventCard(
                  event: content.nextEvent!,
                  registered: content.isRegistered(content.nextEvent!.id),
                  onTap: () => _open(
                    context,
                    EventDetailScreen(eventId: content.nextEvent!.id),
                  ),
                )
              else
                _EmptyHint(
                  text: content.loading
                      ? 'Loading events…'
                      : 'No upcoming events right now.',
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({this.name, required this.streak});
  final String? name;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi${name != null ? ', $name' : ''} 👋',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text('Let’s move today',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentCoral.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppColors.accentCoral, size: 18),
              const SizedBox(width: 4),
              Text('$streak',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No new notifications.')),
          ),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }
}

class _PermissionHint extends StatelessWidget {
  const _PermissionHint({required this.activity});
  final ActivityState activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Enable activity permission to count your steps automatically.',
                ),
              ),
              TextButton(
                onPressed: activity.initTracking,
                child: const Text('Enable'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({required this.workout});
  final Workout? workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (workout == null) {
      return const _EmptyHint(text: 'Loading workouts…');
    }
    final w = workout!;
    return Card(
      color: theme.colorScheme.primary,
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
            Text(w.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${w.totalMinutes} min · ${w.difficultyLabel} · ${w.focus}',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(workoutId: w.id),
                  ),
                ),
                child: const Text('Start workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
