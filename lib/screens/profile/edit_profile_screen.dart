import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../state/activity_state.dart';
import '../../state/session_state.dart';

/// Screen 21 — edit profile: display name, email, password, daily step goal,
/// and (placeholder) profile photo.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late int _stepGoal;

  @override
  void initState() {
    super.initState();
    final user = context.read<SessionState>().session;
    _name = TextEditingController(text: user.displayName ?? '');
    _email = TextEditingController(text: user.email ?? '');
    _password = TextEditingController();
    _stepGoal = user.dailyStepGoal;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<SessionState>();
    final activity = context.read<ActivityState>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final newPassword = _password.text;

    await session.updateProfile(
      displayName: _name.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      dailyStepGoal: _stepGoal,
    );
    await activity.setStepGoal(_stepGoal);

    // Change the account password only if one was entered. Guests have no
    // account, so nothing to update there.
    if (newPassword.isNotEmpty) {
      if (!session.session.isSignedIn) {
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(
            content: Text('Sign in to an account to set a password.')));
        return;
      }
      try {
        await session.changePassword(newPassword);
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
            SnackBar(content: Text(AuthService.messageFor(e))));
        return;
      }
    }

    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Profile updated.')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _name.text.isNotEmpty ? _name.text : 'Guest';
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
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
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary,
                          child: IconButton(
                            iconSize: 16,
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content:
                                        Text('Photo upload coming soon.'))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    helperText: 'Leave blank to keep your current password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) =>
                      (v != null && v.isNotEmpty && v.length < 6)
                          ? 'Password must be at least 6 characters'
                          : null,
                ),
                const SizedBox(height: 24),
                Text('Daily step goal: $_stepGoal',
                    style: theme.textTheme.titleMedium),
                Slider(
                  value: _stepGoal.toDouble(),
                  min: 2000,
                  max: 20000,
                  divisions: 18,
                  label: '$_stepGoal',
                  onChanged: (v) =>
                      setState(() => _stepGoal = (v / 500).round() * 500),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
