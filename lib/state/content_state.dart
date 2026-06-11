import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/intramural_event.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import '../services/local_store.dart';

/// Loads shared content (workouts + events) from the Realtime Database and
/// tracks the current user's event RSVPs (local-first, mirrored to RTDB when
/// signed in).
class ContentState extends ChangeNotifier {
  ContentState({
    required DatabaseService database,
    required LocalStore store,
  })  : _database = database,
        _store = store {
    _rsvps = _store.rsvps.toSet();
  }

  final DatabaseService _database;
  final LocalStore _store;

  List<Workout> _workouts = [];
  List<IntramuralEvent> _events = [];
  Set<String> _rsvps = {};
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  String? _uid;
  String _displayName = 'You';

  List<Workout> get workouts => _workouts;
  List<IntramuralEvent> get events => _events;
  bool get loading => _loading;
  bool get loaded => _loaded;
  String? get error => _error;

  Workout? get featuredWorkout => _workouts.isEmpty
      ? null
      : _workouts.firstWhere((w) => w.isFeatured, orElse: () => _workouts.first);

  List<IntramuralEvent> get upcomingEvents =>
      _events.where((e) => !e.isPast).toList();

  IntramuralEvent? get nextEvent =>
      upcomingEvents.isEmpty ? null : upcomingEvents.first;

  bool isRegistered(String eventId) => _rsvps.contains(eventId);

  List<IntramuralEvent> get myUpcomingEvents =>
      upcomingEvents.where((e) => _rsvps.contains(e.id)).toList();

  List<IntramuralEvent> get myPastEvents =>
      _events.where((e) => e.isPast && _rsvps.contains(e.id)).toList();

  Workout? workoutById(String id) {
    for (final w in _workouts) {
      if (w.id == id) return w;
    }
    return null;
  }

  /// Seeds the DB if needed, then loads workouts and events.
  Future<void> load({bool force = false}) async {
    if (_loading || (_loaded && !force)) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _database.seedIfEmpty();
      _workouts = await _database.fetchWorkouts();
      _events = await _database.fetchEvents();
      _loaded = true;
    } catch (e) {
      _error = 'Couldn’t load content. Check your connection.';
      log('Content load failed: $e', name: 'ContentState');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Whether the current user may create events (signed-in students only).
  bool get canCreateEvents => _uid != null;

  /// Creates a new intramural event organised by the current user and inserts
  /// it into the local list (sorted by start time). Only available to
  /// signed-in students.
  Future<IntramuralEvent> createEvent({
    required String title,
    required String sport,
    required DateTime startTime,
    required String venue,
    required int capacity,
    String description = '',
  }) async {
    if (_uid == null) {
      throw StateError('Only signed-in students can create events.');
    }
    final draft = IntramuralEvent(
      id: '',
      title: title.trim(),
      sport: sport.trim(),
      startTime: startTime,
      venue: venue.trim(),
      organizer: _displayName,
      capacity: capacity,
      description: description.trim(),
    );
    final created = await _database.createEvent(draft);
    _events = [..._events, created]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
    return created;
  }

  Future<void> toggleRsvp(IntramuralEvent event) async {
    final joining = !_rsvps.contains(event.id);
    if (joining) {
      _rsvps.add(event.id);
    } else {
      _rsvps.remove(event.id);
    }
    // Optimistically update the local event participant list.
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      final names = List<String>.from(_events[idx].participantNames);
      if (joining && !names.contains(_displayName)) {
        names.add(_displayName);
      } else if (!joining) {
        names.remove(_displayName);
      }
      _events[idx] = _events[idx].copyWith(participantNames: names);
    }
    notifyListeners();

    await _store.setRsvps(_rsvps.toList());
    try {
      if (joining) {
        await _database.joinEvent(event.id, _displayName);
      } else {
        await _database.leaveEvent(event.id, _displayName);
      }
      if (_uid != null) await _database.writeUserRsvps(_uid!, _rsvps.toList());
    } catch (e) {
      log('RSVP sync failed: $e', name: 'ContentState');
    }
  }

  /// Updates the name used when joining events and the sync target uid.
  void attachUser({String? uid, required String displayName}) {
    _uid = uid;
    if (displayName.trim().isNotEmpty) _displayName = displayName.trim();
  }
}
