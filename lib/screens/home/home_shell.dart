import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/activity_state.dart';
import '../../state/content_state.dart';
import '../events/events_list_screen.dart';
import '../profile/profile_home_screen.dart';
import '../workouts/workouts_list_screen.dart';
import 'dashboard_screen.dart';

/// The persistent app shell: a bottom navigation bar with four tabs whose
/// state is preserved across switches via an [IndexedStack].
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    DashboardScreen(),
    WorkoutsListScreen(),
    EventsListScreen(),
    ProfileHomeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Kick off step tracking and content loading once the shell is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ActivityState>().initTracking();
      context.read<ContentState>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
