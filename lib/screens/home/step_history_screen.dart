import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/activity_state.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/week_bar_chart.dart';
import '../../theme/app_colors.dart';

/// Screen 10 — step history with a week/month toggle, bar chart, and summary
/// stats (daily average, total distance).
class StepHistoryScreen extends StatefulWidget {
  const StepHistoryScreen({super.key});

  @override
  State<StepHistoryScreen> createState() => _StepHistoryScreenState();
}

class _StepHistoryScreenState extends State<StepHistoryScreen> {
  bool _month = false;

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityState>();
    final days = _month ? 30 : 7;
    final data = activity.history(days: days);
    final totalSteps = data.fold<int>(0, (s, d) => s + d.steps);
    final totalDistanceKm = totalSteps * 0.762 / 1000;
    final avg = activity.averageSteps(days: days);

    return Scaffold(
      appBar: AppBar(title: const Text('Step history')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Week')),
                ButtonSegment(value: true, label: Text('Month')),
              ],
              selected: {_month},
              onSelectionChanged: (s) => setState(() => _month = s.first),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                child: StepsBarChart(
                  data: data,
                  goal: activity.stepGoal,
                  height: 220,
                  showWeekdayLabels: !_month,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.directions_walk,
                    value: '${avg.round()}',
                    label: 'Daily average',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    icon: Icons.route,
                    value: '${totalDistanceKm.toStringAsFixed(1)} km',
                    label: 'Total distance',
                    color: AppColors.distanceBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    icon: Icons.functions,
                    value: '$totalSteps',
                    label: 'Total steps',
                    color: AppColors.accentCoral,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
