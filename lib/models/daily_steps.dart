/// Steps recorded for a single calendar day, keyed by an ISO date string
/// (`yyyy-MM-dd`).
class DailySteps {
  const DailySteps({required this.date, required this.steps});

  /// The calendar day, normalised to midnight.
  final DateTime date;
  final int steps;

  /// `yyyy-MM-dd` key used for storage and RTDB nodes.
  String get key => isoKey(date);

  static String isoKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // --- Derived activity estimates -------------------------------------------
  // Simple, transparent conversions used across the dashboard and history.
  static const double _metresPerStep = 0.762;
  static const double _kcalPerStep = 0.04;
  static const double _stepsPerActiveMinute = 100;

  double get distanceKm => steps * _metresPerStep / 1000;
  int get calories => (steps * _kcalPerStep).round();
  int get activeMinutes => (steps / _stepsPerActiveMinute).round();

  DailySteps copyWith({int? steps}) =>
      DailySteps(date: date, steps: steps ?? this.steps);

  Map<String, dynamic> toJson() => {'date': key, 'steps': steps};

  factory DailySteps.fromJson(Map<String, dynamic> json) {
    final raw = json['date'] as String;
    final parts = raw.split('-').map(int.parse).toList();
    return DailySteps(
      date: DateTime(parts[0], parts[1], parts[2]),
      steps: (json['steps'] as num?)?.toInt() ?? 0,
    );
  }
}
