import 'package:flutter/material.dart';

import '../../widgets/app_logo.dart';

/// Screen 20 — About Campus Fit. Introduces the app and its three core
/// features, and shows the version number.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Keep in sync with pubspec.yaml `version:`.
  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Campus Fit')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            const Center(child: AppLogo(size: 110)),
            const SizedBox(height: 20),
            Center(
              child: Text('Campus Fit',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Center(
              child: Text('Your Campus. Your Fitness.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
            const SizedBox(height: 28),
            Text(
              'Campus Fit helps university students stay active around campus '
              '— track your daily steps, fit in quick dorm-room workouts, and '
              'discover intramural sports events with friends.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            const _Feature(
              icon: Icons.directions_walk,
              title: 'Step tracking',
              body: 'Count daily steps and unlock campus zones as you explore.',
            ),
            const _Feature(
              icon: Icons.fitness_center,
              title: 'Dorm workouts',
              body: 'Short, guided routines you can do anywhere, no kit needed.',
            ),
            const _Feature(
              icon: Icons.sports_soccer,
              title: 'Intramural events',
              body: 'Join games and fun runs happening around your campus.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text('Version $appVersion',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
