import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/activity_state.dart';

/// A campus zone unlocked by accumulating steps.
class _Zone {
  const _Zone(this.name, this.icon, this.unlockSteps);
  final String name;
  final IconData icon;
  final int unlockSteps;
}

/// Screen 11 — campus zones: a simple grid of explored vs locked zones to
/// gamify walking. Zones unlock as lifetime steps cross thresholds.
class CampusZonesScreen extends StatelessWidget {
  const CampusZonesScreen({super.key});

  static const _zones = [
    _Zone('Main Quad', Icons.account_balance, 0),
    _Zone('Library', Icons.local_library, 3000),
    _Zone('Sports Hall', Icons.sports_handball, 8000),
    _Zone('Dorms', Icons.apartment, 15000),
    _Zone('Cafeteria', Icons.restaurant, 25000),
    _Zone('Lake Trail', Icons.park, 40000),
    _Zone('Science Block', Icons.science, 60000),
    _Zone('Stadium', Icons.stadium, 90000),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lifetime = context.watch<ActivityState>().lifetimeSteps;
    final unlocked = _zones.where((z) => lifetime >= z.unlockSteps).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Campus zones')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.explore, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$unlocked of ${_zones.length} zones unlocked',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text('Walk more to explore your campus.',
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _zones.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, i) {
                final zone = _zones[i];
                final isUnlocked = lifetime >= zone.unlockSteps;
                return _ZoneTile(zone: zone, unlocked: isUnlocked);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({required this.zone, required this.unlocked});
  final _Zone zone;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            unlocked ? zone.icon : Icons.lock_outline,
            size: 36,
            color: unlocked
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(zone.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            unlocked ? 'Explored' : 'Unlock at ${zone.unlockSteps}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
