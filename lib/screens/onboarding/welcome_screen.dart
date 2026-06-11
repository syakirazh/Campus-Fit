import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../account/guest_start_screen.dart';
import '../account/log_in_screen.dart';
import '../account/sign_up_screen.dart';

/// Screen 5 — welcome with three entry options. Guest is the low-friction
/// default and is given the most prominent (brand-coloured) treatment.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const AppLogo(size: 130),
              const SizedBox(height: 28),
              Text(
                'Campus Fit',
                style: theme.textTheme.displaySmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Move more. Together.',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const Spacer(flex: 3),
              // Continue as guest — the default, highest-emphasis action.
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      _push(context, const GuestStartScreen()),
                  child: const Text('Continue as guest'),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Explore without an account',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _push(context, const SignUpScreen()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text('Create account'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _push(context, const LogInScreen()),
                child: const Text(
                  'I already have an account · Log in',
                  style: TextStyle(color: AppColors.brandTeal),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
