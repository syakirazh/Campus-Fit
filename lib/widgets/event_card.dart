import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/intramural_event.dart';
import '../theme/app_colors.dart';

/// Card summarising an intramural event. Events use the coral accent.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.registered = false,
  });

  final IntramuralEvent event;
  final VoidCallback? onTap;
  final bool registered;

  static IconData iconForSport(String sport) => switch (sport.toLowerCase()) {
        'futsal' || 'football' || 'soccer' => Icons.sports_soccer,
        'badminton' || 'tennis' => Icons.sports_tennis,
        'basketball' => Icons.sports_basketball,
        'running' => Icons.directions_run,
        _ => Icons.emoji_events,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE d MMM · h:mm a').format(event.startTime);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconForSport(event.sport),
                    color: AppColors.accentCoral),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(event.title,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        if (registered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Joined',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(dateLabel,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    Text('${event.venue} · ${event.joinedCount} joined',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
