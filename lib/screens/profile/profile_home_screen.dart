import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/activity_state.dart';
import '../../state/session_state.dart';
import '../../widgets/stat_tile.dart';
import '../../theme/app_colors.dart';
import '../account/sign_up_screen.dart';
import '../onboarding/welcome_screen.dart';
import 'about_screen.dart';
import 'achievements_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

/// Screen 19 — profile home: avatar, name, lifetime stats, and a menu list.
/// In guest mode, shows a "create an account to save your progress" prompt.
class ProfileHomeScreen extends StatelessWidget {
  const ProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionState>();
    final activity = context.watch<ActivityState>();
    final user = session.session;
    final name = user.displayName ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _open(context, const SettingsScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          // Always allow dragging even when the content nearly fits, and leave
          // room at the bottom so the last menu item clears the nav bar.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  user.isSignedIn
                      ? (user.email ?? 'Signed in')
                      : 'Guest mode',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.directions_walk,
                    value: '${activity.lifetimeSteps}',
                    label: 'Steps',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    icon: Icons.fitness_center,
                    value: '${activity.workoutsCompleted}',
                    label: 'Workouts',
                    color: AppColors.distanceBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    icon: Icons.local_fire_department,
                    value: '${activity.streak}',
                    label: 'Day streak',
                    color: AppColors.accentCoral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (user.isGuest) _GuestPrompt(),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.edit_outlined,
              title: 'Edit profile',
              onTap: () => _open(context, const EditProfileScreen()),
            ),
            _MenuTile(
              icon: Icons.emoji_events_outlined,
              title: 'Achievements',
              onTap: () => _open(context, const AchievementsScreen()),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => _open(context, const SettingsScreen()),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              title: 'About Campus Fit',
              onTap: () => _open(context, const AboutScreen()),
            ),
            _MenuTile(
              icon: Icons.logout,
              title: user.isSignedIn ? 'Sign out' : 'Log out',
              onTap: () => _logOut(context),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
}

class _GuestPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.cloud_upload_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Save your progress',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text('Create an account to back up and sync your data.',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              ),
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
