import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/daily_steps.dart';

/// A simple bar chart of daily steps. Used for the dashboard "this week" view
/// and the step-history screen (which can pass a month of data).
class StepsBarChart extends StatelessWidget {
  const StepsBarChart({
    super.key,
    required this.data,
    required this.goal,
    this.height = 180,
    this.showWeekdayLabels = true,
  });

  final List<DailySteps> data;
  final int goal;
  final double height;
  final bool showWeekdayLabels;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSteps = data.fold<int>(
      goal,
      (m, d) => d.steps > m ? d.steps : m,
    );
    final maxY = (maxSteps * 1.2).ceilToDouble();

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 1000 : maxY,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${rod.toY.round()}',
                theme.textTheme.bodySmall!
                    .copyWith(color: theme.colorScheme.onInverseSurface),
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  final label = showWeekdayLabels
                      ? _weekdays[data[i].date.weekday - 1]
                      : '${data[i].date.day}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label, style: theme.textTheme.bodySmall),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].steps.toDouble(),
                    width: showWeekdayLabels ? 18 : 8,
                    borderRadius: BorderRadius.circular(6),
                    color: data[i].steps >= goal
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
