import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/intramural_event.dart';
import '../../state/content_state.dart';
import '../../widgets/event_card.dart';

/// Screen 17 — event detail with date/time, venue, players joined, organizer,
/// participant avatars, and a join button.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = context.watch<ContentState>();
    IntramuralEvent? event;
    for (final e in content.events) {
      if (e.id == eventId) {
        event = e;
        break;
      }
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: const Center(child: Text('Event not found.')),
      );
    }

    final registered = content.isRegistered(event.id);
    final dateLabel = DateFormat('EEEE, d MMMM').format(event.startTime);
    final timeLabel = DateFormat('h:mm a').format(event.startTime);

    return Scaffold(
      appBar: AppBar(title: Text(event.sport)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(EventCard.iconForSport(event.sport),
                      size: 32, color: theme.colorScheme.secondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('Organised by ${event.organizer}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _InfoRow(icon: Icons.calendar_today, text: dateLabel),
            _InfoRow(icon: Icons.schedule, text: timeLabel),
            _InfoRow(icon: Icons.place, text: event.venue),
            _InfoRow(
              icon: Icons.group,
              text: '${event.joinedCount} of ${event.capacity} joined',
            ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(event.description, style: theme.textTheme.bodyLarge),
            ],
            const SizedBox(height: 24),
            Text('Participants',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _ParticipantAvatars(names: event.participantNames),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: registered
                  ? FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: theme.colorScheme.onSurface,
                    )
                  : null,
              onPressed: (!registered && event.isFull)
                  ? null
                  : () => _toggle(context, content, event!),
              icon: Icon(registered ? Icons.check : Icons.add),
              label: Text(registered
                  ? 'Joined — tap to leave'
                  : event.isFull
                      ? 'Event full'
                      : 'Join event'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(
      BuildContext context, ContentState content, IntramuralEvent event) async {
    final registered = content.isRegistered(event.id);
    await content.toggleRsvp(event);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(registered
            ? 'You left ${event.title}.'
            : 'You joined ${event.title}!'),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _ParticipantAvatars extends StatelessWidget {
  const _ParticipantAvatars({required this.names});
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (names.isEmpty) {
      return Text('Be the first to join!',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant));
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final name in names)
          Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 56,
                child: Text(name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall),
              ),
            ],
          ),
      ],
    );
  }
}
