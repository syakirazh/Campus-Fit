import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../state/activity_state.dart';
import 'workout_complete_screen.dart';

/// Screen 14 — the in-progress workout player. A full-screen countdown timer
/// per exercise, showing the current and next move, with pause/skip controls.
class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({super.key, required this.workout});

  final Workout workout;

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  Timer? _timer;
  int _index = 0;
  late int _remaining;
  bool _paused = false;
  final _start = DateTime.now();

  Exercise get _current => widget.workout.exercises[_index];
  Exercise? get _next => _index + 1 < widget.workout.exercises.length
      ? widget.workout.exercises[_index + 1]
      : null;

  @override
  void initState() {
    super.initState();
    _remaining = _current.durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      if (_remaining > 1) {
        setState(() => _remaining--);
      } else {
        _advance();
      }
    });
  }

  void _advance() {
    if (_index + 1 < widget.workout.exercises.length) {
      setState(() {
        _index++;
        _remaining = _current.durationSeconds;
      });
    } else {
      _finish();
    }
  }

  void _skip() => _advance();

  void _togglePause() => setState(() => _paused = !_paused);

  Future<void> _finish() async {
    _timer?.cancel();
    final elapsed = DateTime.now().difference(_start);
    final activity = context.read<ActivityState>();
    await activity.recordWorkoutCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutCompleteScreen(
          workout: widget.workout,
          elapsed: elapsed,
          newStreak: activity.streak,
        ),
      ),
    );
  }

  Future<bool> _confirmQuit() async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End workout?'),
        content: const Text('Your progress for this session won’t be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    return quit ?? false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _current.durationSeconds;
    final progress = total == 0 ? 0.0 : (total - _remaining) / total;
    final step = '${_index + 1} / ${widget.workout.exercises.length}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmQuit() && mounted) navigator.pop();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        if (await _confirmQuit() && mounted) {
                          navigator.pop();
                        }
                      },
                      icon: Icon(Icons.close,
                          color: theme.colorScheme.onPrimary),
                    ),
                    Text(step,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary)),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                          backgroundColor:
                              theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation(
                              theme.colorScheme.onPrimary),
                        ),
                      ),
                      Text('$_remaining',
                          style: theme.textTheme.displayLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(_current.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (_current.description.isNotEmpty)
                  Text(_current.description,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.85))),
                const SizedBox(height: 12),
                Text(
                  _next != null ? 'Next: ${_next!.name}' : 'Last exercise!',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          theme.colorScheme.onPrimary.withValues(alpha: 0.7)),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PlayerButton(
                      icon: _paused ? Icons.play_arrow : Icons.pause,
                      label: _paused ? 'Resume' : 'Pause',
                      onTap: _togglePause,
                    ),
                    _PlayerButton(
                      icon: Icons.skip_next,
                      label: 'Skip',
                      onTap: _skip,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerButton extends StatelessWidget {
  const _PlayerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          iconSize: 32,
          padding: const EdgeInsets.all(18),
          icon: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: onPrimary)),
      ],
    );
  }
}
