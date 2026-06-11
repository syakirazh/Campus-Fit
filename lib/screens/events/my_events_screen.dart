import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/content_state.dart';
import '../../widgets/event_card.dart';
import 'event_detail_screen.dart';

/// Screen 18 — "my events" split into registered (upcoming) and past events.
class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentState>();
    final upcoming = content.myUpcomingEvents;
    final past = content.myPastEvents;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My events'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Registered'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _EventList(
                events: upcoming,
                emptyText: 'You haven’t joined any upcoming events yet.',
                registered: true,
              ),
              _EventList(
                events: past,
                emptyText: 'No past events.',
                registered: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.events,
    required this.emptyText,
    required this.registered,
  });

  final List events;
  final String emptyText;
  final bool registered;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyText, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final event = events[i];
        return EventCard(
          event: event,
          registered: registered,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id),
            ),
          ),
        );
      },
    );
  }
}
