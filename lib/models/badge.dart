import 'package:flutter/material.dart';

/// An achievement badge. Whether it is earned is computed from the user's
/// lifetime stats (see `AchievementsScreen`), so the catalogue itself is a
/// fixed list of definitions.
class AchievementBadge {
  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;

  /// The full catalogue of badges Campus Fit can award.
  static const List<AchievementBadge> catalogue = [
    AchievementBadge(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Log your first 1,000 steps',
      icon: Icons.directions_walk,
    ),
    AchievementBadge(
      id: 'goal_getter',
      title: 'Goal Getter',
      description: 'Hit your daily step goal',
      icon: Icons.flag,
    ),
    AchievementBadge(
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Keep a 7-day streak',
      icon: Icons.local_fire_department,
    ),
    AchievementBadge(
      id: 'dorm_athlete',
      title: 'Dorm Athlete',
      description: 'Finish 5 workouts',
      icon: Icons.fitness_center,
    ),
    AchievementBadge(
      id: 'team_player',
      title: 'Team Player',
      description: 'Join an intramural event',
      icon: Icons.sports_soccer,
    ),
    AchievementBadge(
      id: 'explorer',
      title: 'Explorer',
      description: 'Unlock 3 campus zones',
      icon: Icons.explore,
    ),
  ];
}
