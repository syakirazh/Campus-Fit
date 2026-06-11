/// A single move within a workout routine.
class Exercise {
  const Exercise({
    required this.name,
    required this.durationSeconds,
    this.description = '',
  });

  final String name;
  final int durationSeconds;
  final String description;

  Map<String, dynamic> toJson() => {
        'name': name,
        'durationSeconds': durationSeconds,
        'description': description,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json['name'] as String? ?? 'Exercise',
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 30,
        description: json['description'] as String? ?? '',
      );
}

enum WorkoutDifficulty { easy, medium, hard }

/// A short dorm-room workout routine.
class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.equipment,
    required this.exercises,
    this.focus = '',
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final WorkoutDifficulty difficulty;
  final String equipment;
  final List<Exercise> exercises;
  final String focus;
  final bool isFeatured;

  /// Total routine length in seconds (sum of exercise durations).
  int get totalSeconds =>
      exercises.fold(0, (sum, e) => sum + e.durationSeconds);

  int get totalMinutes => (totalSeconds / 60).ceil();

  /// Rough calorie estimate (~8 kcal/min of bodyweight work).
  int get estimatedCalories => (totalSeconds / 60 * 8).round();

  String get difficultyLabel => switch (difficulty) {
        WorkoutDifficulty.easy => 'Easy',
        WorkoutDifficulty.medium => 'Medium',
        WorkoutDifficulty.hard => 'Hard',
      };

  Map<String, dynamic> toJson() => {
        'title': title,
        'difficulty': difficulty.name,
        'equipment': equipment,
        'focus': focus,
        'isFeatured': isFeatured,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory Workout.fromJson(String id, Map<String, dynamic> json) {
    final rawExercises = (json['exercises'] as List<dynamic>? ?? [])
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return Workout(
      id: id,
      title: json['title'] as String? ?? 'Workout',
      difficulty: WorkoutDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => WorkoutDifficulty.easy,
      ),
      equipment: json['equipment'] as String? ?? 'No equipment',
      focus: json['focus'] as String? ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
      exercises: rawExercises,
    );
  }
}
