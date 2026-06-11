import 'package:flutter/material.dart';

/// Circular progress ring showing today's steps against the daily goal.
class StepRing extends StatelessWidget {
  const StepRing({
    super.key,
    required this.steps,
    required this.goal,
    this.size = 200,
  });

  final int steps;
  final int goal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal == 0 ? 0.0 : (steps / goal).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: size * 0.06,
              strokeCap: StrokeCap.round,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.12),
              valueColor:
                  AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_walk,
                  color: theme.colorScheme.primary, size: size * 0.13),
              const SizedBox(height: 4),
              Text(
                '$steps',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              Text(
                'of $goal steps',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
