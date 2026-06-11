import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_state.dart';
import '../../widgets/app_logo.dart';
import '../home/home_shell.dart';

/// Screen 8 — guest start. Set a display name (skippable), then enter the app.
class GuestStartScreen extends StatefulWidget {
  const GuestStartScreen({super.key});

  @override
  State<GuestStartScreen> createState() => _GuestStartScreenState();
}

class _GuestStartScreenState extends State<GuestStartScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _enter({required bool withName}) async {
    final session = context.read<SessionState>();
    final navigator = Navigator.of(context);
    await session.continueAsGuest(
      displayName: withName ? _name.text : null,
    );
    await session.markEntered();
    if (!mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Continue as guest')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Center(child: AppLogo(size: 96)),
              const SizedBox(height: 28),
              Text(
                'What should we call you?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'This helps personalise your dashboard. You can change it later.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _enter(withName: true),
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => _enter(withName: true),
                child: const Text('Start exploring'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _enter(withName: false),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
