import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/content_state.dart';
import '../../widgets/event_card.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';
import 'my_events_screen.dart';

/// Screen 16 — events list of upcoming intramural games and runs.
class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentState>();
    final events = content.upcomingEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            tooltip: 'My events',
            icon: const Icon(Icons.event_available),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyEventsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _body(context, content, events),
      ),
      // Signed-in students can organise their own intramural events.
      floatingActionButton: content.canCreateEvents
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add event'),
            )
          : null,
    );
  }

  Widget _body(BuildContext context, ContentState content, List events) {
    if (content.loading && content.events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (content.events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy, size: 48),
              const SizedBox(height: 16),
              Text(content.error ?? 'No events found.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => content.load(force: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => content.load(force: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final event = events[i];
          return EventCard(
            event: event,
            registered: content.isRegistered(event.id),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(eventId: event.id),
              ),
            ),
          );
        },
      ),
    );
  }
}
