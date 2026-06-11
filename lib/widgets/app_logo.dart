import 'package:flutter/material.dart';

/// Brand mark for Campus Fit — the CampusFit logo image, clipped to a circle
/// (matching the rounded logo in the splash design). Used on the splash,
/// welcome, auth, and about screens.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
