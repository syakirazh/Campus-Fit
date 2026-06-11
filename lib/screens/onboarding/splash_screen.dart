import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../state/session_state.dart';
import '../../widgets/app_logo.dart';
import '../home/home_shell.dart';
import 'intro_flow.dart';
import 'welcome_screen.dart';

/// Screen 1 — branding splash shown on launch. Waits for the session to
/// initialise (and a short minimum display), then routes to the right place.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the countdown only after the first frame is actually painted, so
    // the splash is visible for the full duration even when a slow native
    // launch screen was covering it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideNext());
  }

  Future<void> _decideNext() async {
    final session = context.read<SessionState>();
    final started = DateTime.now();

    // Wait until the session has restored.
    while (!session.initialized) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
    }
    // Keep the splash up for at least 1.6s of visible time for a polished feel.
    final elapsed = DateTime.now().difference(started);
    const minimum = Duration(milliseconds: 1600);
    if (elapsed < minimum) {
      await Future<void>.delayed(minimum - elapsed);
    }
    if (!mounted) return;

    final Widget next;
    if (session.session.isSignedIn || session.appEntered) {
      next = const HomeShell();
    } else if (!session.seenOnboarding) {
      next = const IntroFlow();
    } else {
      next = const WelcomeScreen();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 220),
            const SizedBox(height: 28),
            Text(
              'Your Campus. Your Fitness.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
