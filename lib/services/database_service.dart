import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';

import '../models/intramural_event.dart';
import '../models/workout.dart';
import 'seed_data.dart';

/// All Realtime Database access lives here.
///
/// Content (`/workouts`, `/events`) is shared and read by everyone; per-user
/// data is namespaced under `/users/{uid}` and only synced for signed-in users.
class DatabaseService {
  DatabaseService(this._db);

  final FirebaseDatabase _db;

  DatabaseReference get _workoutsRef => _db.ref('workouts');
  DatabaseReference get _eventsRef => _db.ref('events');
  DatabaseReference _userRef(String uid) => _db.ref('users/$uid');

  /// Seeds `/workouts` and `/events` if they are empty, so a fresh project has
  /// content to read. Safe to call on every launch — it is a no-op once data
  /// exists.
  Future<void> seedIfEmpty() async {
    try {
      final workoutsSnap = await _workoutsRef.get();
      if (!workoutsSnap.exists) {
        await _workoutsRef.set(SeedData.workouts());
        log('Seeded /workouts', name: 'DatabaseService');
      }
      final eventsSnap = await _eventsRef.get();
      if (!eventsSnap.exists) {
        await _eventsRef.set(SeedData.events());
        log('Seeded /events', name: 'DatabaseService');
      }
    } catch (e) {
      log('Seeding skipped: $e', name: 'DatabaseService');
    }
  }

  // --- Content reads ---------------------------------------------------------
  Future<List<Workout>> fetchWorkouts() async {
    final snap = await _workoutsRef.get();
    if (!snap.exists) return [];
    final map = Map<String, dynamic>.from(snap.value as Map);
    return map.entries
        .map((e) => Workout.fromJson(e.key, Map<String, dynamic>.from(e.value)))
        .toList();
  }

  /// Creates a new workout under `/workouts` and returns it with its id.
  Future<Workout> createWorkout(Workout workout) async {
    final ref = _workoutsRef.push();
    await ref.set(workout.toJson());
    return Workout(
      id: ref.key!,
      title: workout.title,
      difficulty: workout.difficulty,
      equipment: workout.equipment,
      exercises: workout.exercises,
      focus: workout.focus,
      isFeatured: workout.isFeatured,
    );
  }

  Future<List<IntramuralEvent>> fetchEvents() async {
    final snap = await _eventsRef.get();
    if (!snap.exists) return [];
    final map = Map<String, dynamic>.from(snap.value as Map);
    final events = map.entries
        .map((e) =>
            IntramuralEvent.fromJson(e.key, Map<String, dynamic>.from(e.value)))
        .toList();
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events;
  }

  /// Creates a new event under `/events` and returns its generated id.
  Future<IntramuralEvent> createEvent(IntramuralEvent event) async {
    final ref = _eventsRef.push();
    await ref.set(event.toJson());
    return IntramuralEvent(
      id: ref.key!,
      title: event.title,
      sport: event.sport,
      startTime: event.startTime,
      venue: event.venue,
      organizer: event.organizer,
      capacity: event.capacity,
      participantNames: event.participantNames,
      description: event.description,
    );
  }

  /// Adds a participant to an event using a transaction so the join count is
  /// consistent across users.
  Future<void> joinEvent(String eventId, String participantName) async {
    final ref = _eventsRef.child('$eventId/participantNames');
    await ref.runTransaction((current) {
      final list = current == null
          ? <dynamic>[]
          : List<dynamic>.from(current as List);
      if (!list.contains(participantName)) list.add(participantName);
      return Transaction.success(list);
    });
  }

  Future<void> leaveEvent(String eventId, String participantName) async {
    final ref = _eventsRef.child('$eventId/participantNames');
    await ref.runTransaction((current) {
      final list = current == null
          ? <dynamic>[]
          : List<dynamic>.from(current as List);
      list.remove(participantName);
      return Transaction.success(list);
    });
  }

  // --- Per-user sync ---------------------------------------------------------
  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    final snap = await _userRef(uid).get();
    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  Future<void> writeUserProfile(String uid, Map<String, dynamic> profile) =>
      _userRef(uid).child('profile').update(profile);

  Future<void> writeUserSteps(String uid, Map<String, int> stepsByDay) =>
      _userRef(uid).child('steps').set(stepsByDay);

  Future<void> writeUserRsvps(String uid, List<String> rsvps) =>
      _userRef(uid).child('rsvps').set(rsvps);

  Future<void> writeWorkoutsCompleted(String uid, int count) =>
      _userRef(uid).child('workoutsCompleted').set(count);

  /// Pushes a full local snapshot up — used when a guest creates an account.
  Future<void> migrateGuestData(
    String uid, {
    required Map<String, dynamic> profile,
    required Map<String, int> stepsByDay,
    required List<String> rsvps,
    required int workoutsCompleted,
  }) async {
    await _userRef(uid).update({
      'profile': profile,
      'steps': stepsByDay,
      'rsvps': rsvps,
      'workoutsCompleted': workoutsCompleted,
    });
  }
}
