import '../models/intramural_event.dart';
import '../models/workout.dart';

/// Default content written to the Realtime Database the first time the app
/// runs against an empty `/workouts` or `/events` node (see [DatabaseService]).
/// This lets a fresh Firebase project come up populated without manual import.
class SeedData {
  SeedData._();

  static Map<String, dynamic> workouts() => {
        'morning_energizer': const Workout(
          id: 'morning_energizer',
          title: 'Morning Energizer',
          difficulty: WorkoutDifficulty.easy,
          equipment: 'No equipment',
          focus: 'Full body wake-up',
          isFeatured: true,
          exercises: [
            Exercise(name: 'Jumping Jacks', durationSeconds: 40, description: 'Keep a steady rhythm.'),
            Exercise(name: 'Bodyweight Squats', durationSeconds: 40, description: 'Sit back into your heels.'),
            Exercise(name: 'Arm Circles', durationSeconds: 30, description: 'Forward then backward.'),
            Exercise(name: 'High Knees', durationSeconds: 40, description: 'Drive knees to hip height.'),
            Exercise(name: 'Stretch & Reset', durationSeconds: 30, description: 'Reach tall and breathe.'),
          ],
        ).toJson(),
        'core_crusher': const Workout(
          id: 'core_crusher',
          title: 'Core Crusher',
          difficulty: WorkoutDifficulty.medium,
          equipment: 'Mat',
          focus: 'Abs & core',
          exercises: [
            Exercise(name: 'Plank', durationSeconds: 45, description: 'Hips level, core tight.'),
            Exercise(name: 'Bicycle Crunches', durationSeconds: 40, description: 'Slow and controlled.'),
            Exercise(name: 'Leg Raises', durationSeconds: 40, description: 'Lower legs without arching.'),
            Exercise(name: 'Russian Twists', durationSeconds: 40, description: 'Rotate from the waist.'),
            Exercise(name: 'Side Plank', durationSeconds: 45, description: 'Switch halfway.'),
          ],
        ).toJson(),
        'dorm_hiit': const Workout(
          id: 'dorm_hiit',
          title: 'Dorm HIIT',
          difficulty: WorkoutDifficulty.hard,
          equipment: 'No equipment',
          focus: 'Cardio burn',
          exercises: [
            Exercise(name: 'Burpees', durationSeconds: 40, description: 'Explode up each rep.'),
            Exercise(name: 'Mountain Climbers', durationSeconds: 40, description: 'Fast but controlled.'),
            Exercise(name: 'Jump Squats', durationSeconds: 40, description: 'Land soft.'),
            Exercise(name: 'Plank Jacks', durationSeconds: 40, description: 'Keep hips steady.'),
            Exercise(name: 'Rest', durationSeconds: 20, description: 'Catch your breath.'),
            Exercise(name: 'Sprint in Place', durationSeconds: 40, description: 'Pump those arms.'),
          ],
        ).toJson(),
        'recovery_stretch': const Workout(
          id: 'recovery_stretch',
          title: 'Recovery Stretch',
          difficulty: WorkoutDifficulty.easy,
          equipment: 'Mat',
          focus: 'Mobility & recovery',
          exercises: [
            Exercise(name: 'Neck Rolls', durationSeconds: 30, description: 'Gentle and slow.'),
            Exercise(name: 'Shoulder Stretch', durationSeconds: 40, description: 'Both sides.'),
            Exercise(name: 'Hamstring Stretch', durationSeconds: 40, description: 'Hinge at the hips.'),
            Exercise(name: 'Hip Opener', durationSeconds: 40, description: 'Breathe into it.'),
            Exercise(name: 'Child’s Pose', durationSeconds: 50, description: 'Relax fully.'),
          ],
        ).toJson(),
      };

  static Map<String, dynamic> events() {
    final now = DateTime.now();
    DateTime at(int daysFromNow, int hour) => DateTime(
          now.year,
          now.month,
          now.day,
          hour,
        ).add(Duration(days: daysFromNow));

    return {
      'futsal_night': IntramuralEvent(
        id: 'futsal_night',
        title: 'Futsal Friday',
        sport: 'Futsal',
        startTime: at(2, 19),
        venue: 'Sports Hall Court 2',
        organizer: 'Intramural Council',
        capacity: 10,
        description: '5-a-side futsal, all skill levels welcome.',
        participantNames: const ['Aisha', 'Marcus', 'Priya', 'Leo'],
      ).toJson(),
      'badminton_open': IntramuralEvent(
        id: 'badminton_open',
        title: 'Badminton Open',
        sport: 'Badminton',
        startTime: at(4, 17),
        venue: 'Gym Hall A',
        organizer: 'Racquet Society',
        capacity: 16,
        description: 'Doubles ladder — bring your own racquet.',
        participantNames: const ['Sara', 'Tom', 'Wei'],
      ).toJson(),
      'campus_fun_run': IntramuralEvent(
        id: 'campus_fun_run',
        title: 'Campus 5K Fun Run',
        sport: 'Running',
        startTime: at(6, 8),
        venue: 'Main Quad start line',
        organizer: 'Campus Fit',
        capacity: 60,
        description: 'A relaxed 5K loop around campus. Walkers welcome.',
        participantNames: const ['Dana', 'Omar', 'Ivy', 'Noah', 'Grace'],
      ).toJson(),
      'basketball_pickup': IntramuralEvent(
        id: 'basketball_pickup',
        title: 'Pickup Basketball',
        sport: 'Basketball',
        startTime: at(1, 20),
        venue: 'Outdoor Courts',
        organizer: 'Hoops Club',
        capacity: 12,
        description: 'Casual pickup games, rotating teams.',
        participantNames: const ['Jay', 'Mina'],
      ).toJson(),
    };
  }
}
