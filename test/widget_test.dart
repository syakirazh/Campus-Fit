// Unit tests for Campus Fit's domain models. These avoid Firebase/widget
// bootstrapping so they run fast and deterministically.

import 'package:flutter_test/flutter_test.dart';

import 'package:campus_fit/models/daily_steps.dart';
import 'package:campus_fit/models/workout.dart';

void main() {
  group('DailySteps', () {
    test('derives distance, calories and active minutes from steps', () {
      final day = DailySteps(date: DateTime(2026, 6, 11), steps: 10000);
      expect(day.key, '2026-06-11');
      expect(day.distanceKm, closeTo(7.62, 0.001));
      expect(day.calories, 400);
      expect(day.activeMinutes, 100);
    });

    test('round-trips through json', () {
      final day = DailySteps(date: DateTime(2026, 1, 2), steps: 5);
      final restored = DailySteps.fromJson(day.toJson());
      expect(restored.key, day.key);
      expect(restored.steps, 5);
    });
  });

  group('Workout', () {
    final workout = Workout(
      id: 'w1',
      title: 'Test',
      difficulty: WorkoutDifficulty.medium,
      equipment: 'None',
      exercises: const [
        Exercise(name: 'A', durationSeconds: 60),
        Exercise(name: 'B', durationSeconds: 90),
      ],
    );

    test('sums exercise durations', () {
      expect(workout.totalSeconds, 150);
      expect(workout.totalMinutes, 3);
    });

    test('round-trips through json', () {
      final restored = Workout.fromJson('w1', workout.toJson());
      expect(restored.exercises.length, 2);
      expect(restored.difficulty, WorkoutDifficulty.medium);
      expect(restored.totalSeconds, 150);
    });
  });
}
