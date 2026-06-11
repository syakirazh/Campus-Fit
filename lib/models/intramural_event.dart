/// An upcoming intramural game or fun run students can join.
class IntramuralEvent {
  const IntramuralEvent({
    required this.id,
    required this.title,
    required this.sport,
    required this.startTime,
    required this.venue,
    required this.organizer,
    this.capacity = 20,
    this.participantNames = const [],
    this.description = '',
  });

  final String id;
  final String title;
  final String sport;
  final DateTime startTime;
  final String venue;
  final String organizer;
  final int capacity;
  final List<String> participantNames;
  final String description;

  int get joinedCount => participantNames.length;
  bool get isFull => joinedCount >= capacity;
  bool get isPast => startTime.isBefore(DateTime.now());

  IntramuralEvent copyWith({List<String>? participantNames}) {
    return IntramuralEvent(
      id: id,
      title: title,
      sport: sport,
      startTime: startTime,
      venue: venue,
      organizer: organizer,
      capacity: capacity,
      participantNames: participantNames ?? this.participantNames,
      description: description,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'sport': sport,
        'startTime': startTime.toIso8601String(),
        'venue': venue,
        'organizer': organizer,
        'capacity': capacity,
        'description': description,
        'participantNames': participantNames,
      };

  factory IntramuralEvent.fromJson(String id, Map<String, dynamic> json) {
    return IntramuralEvent(
      id: id,
      title: json['title'] as String? ?? 'Event',
      sport: json['sport'] as String? ?? 'Sport',
      startTime:
          DateTime.tryParse(json['startTime'] as String? ?? '') ?? DateTime.now(),
      venue: json['venue'] as String? ?? 'Campus',
      organizer: json['organizer'] as String? ?? 'Campus Fit',
      capacity: (json['capacity'] as num?)?.toInt() ?? 20,
      description: json['description'] as String? ?? '',
      participantNames: (json['participantNames'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
