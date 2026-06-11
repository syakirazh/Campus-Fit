import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../state/activity_state.dart';
import '../../state/session_state.dart';
import '../../state/settings_state.dart';
import '../onboarding/welcome_screen.dart';
import 'about_screen.dart';

/// Screen 23 — settings: notifications toggle, daily step goal, units, theme,
/// and privacy.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsState>();
    final activity = context.watch<ActivityState>();
    final session = context.watch<SessionState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Notifications'),
            Card(
              child: SwitchListTile(
                title: const Text('Reminders & streak alerts'),
                subtitle:
                    const Text('Get nudges to keep your streak alive.'),
                value: settings.notificationsEnabled,
                onChanged: (v) => _toggleNotifications(context, settings, v),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Activity'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Daily step goal'),
                trailing: Text('${activity.stepGoal}',
                    style: theme.textTheme.titleMedium),
                onTap: () => _editGoal(context, activity),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Units'),
            Card(
              child: RadioGroup<bool>(
                groupValue: settings.unitsMetric,
                onChanged: (v) => settings.setUnitsMetric(v ?? true),
                child: const Column(
                  children: [
                    RadioListTile<bool>(
                      title: Text('Metric (km)'),
                      value: true,
                    ),
                    RadioListTile<bool>(
                      title: Text('Imperial (miles)'),
                      value: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Appearance'),
            Card(
              child: RadioGroup<ThemeMode>(
                groupValue: settings.themeMode,
                onChanged: (v) => settings.setThemeMode(v ?? ThemeMode.system),
                child: Column(
                  children: [
                    for (final mode in ThemeMode.values)
                      RadioListTile<ThemeMode>(
                        title: Text(_themeLabel(mode)),
                        value: mode,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Privacy & info'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy'),
                    subtitle: const Text(
                        'Your step and activity data stays on your device '
                        'unless you sign in to sync.'),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Privacy'),
                        content: const Text(
                          'Campus Fit stores guest data locally on your device. '
                          'When you create an account, your data is synced to '
                          'your private Firebase profile and is not shared with '
                          'other users. Event participation shows only your '
                          'display name to other participants.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About Campus Fit'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Account'),
            Card(
              child: ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  session.session.isSignedIn ? 'Sign out' : 'Log out',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => _logOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logOut(BuildContext context) async {
    final signedIn = context.read<SessionState>().session.isSignedIn;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(signedIn ? 'Sign out?' : 'Log out?'),
        content: Text(signedIn
            ? 'You can sign back in anytime to sync your progress.'
            : 'You can continue as a guest or sign in again from the welcome '
                'screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(signedIn ? 'Sign out' : 'Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SessionState>().logOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System default',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  Future<void> _toggleNotifications(
      BuildContext context, SettingsState settings, bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (!context.mounted) return;
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Notification permission denied in system settings.')),
        );
        await settings.setNotificationsEnabled(false);
        return;
      }
    }
    await settings.setNotificationsEnabled(value);
  }

  Future<void> _editGoal(BuildContext context, ActivityState activity) async {
    var goal = activity.stepGoal;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Daily step goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$goal steps',
                  style: Theme.of(context).textTheme.headlineSmall),
              Slider(
                value: goal.toDouble(),
                min: 2000,
                max: 20000,
                divisions: 18,
                label: '$goal',
                onChanged: (v) =>
                    setState(() => goal = (v / 500).round() * 500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, goal),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result != null) await activity.setStepGoal(result);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    );
  }
}
