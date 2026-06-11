import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../state/content_state.dart';

/// Lets a signed-in student build their own workout routine — a title, a few
/// details, and an ordered list of timed exercises — and publish it so it
/// appears in the shared workouts list.
class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _ExerciseDraft {
  _ExerciseDraft()
      : name = TextEditingController(),
        seconds = 30;
  final TextEditingController name;
  int seconds;
  void dispose() => name.dispose();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _equipment = TextEditingController(text: 'No equipment');
  final _focus = TextEditingController();
  WorkoutDifficulty _difficulty = WorkoutDifficulty.easy;
  final List<_ExerciseDraft> _exercises = [_ExerciseDraft()];
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _equipment.dispose();
    _focus.dispose();
    for (final e in _exercises) {
      e.dispose();
    }
    super.dispose();
  }

  void _addExercise() => setState(() => _exercises.add(_ExerciseDraft()));

  void _removeExercise(int i) {
    setState(() {
      _exercises.removeAt(i).dispose();
    });
  }

  String _difficultyLabel(WorkoutDifficulty d) => switch (d) {
        WorkoutDifficulty.easy => 'Easy',
        WorkoutDifficulty.medium => 'Medium',
        WorkoutDifficulty.hard => 'Hard',
      };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final named = _exercises
        .where((e) => e.name.text.trim().isNotEmpty)
        .toList();
    if (named.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise.')),
      );
      return;
    }

    final content = context.read<ContentState>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      await content.createWorkout(
        title: _title.text,
        difficulty: _difficulty,
        equipment: _equipment.text.trim().isEmpty
            ? 'No equipment'
            : _equipment.text,
        focus: _focus.text,
        exercises: [
          for (final e in named)
            Exercise(name: e.name.text.trim(), durationSeconds: e.seconds),
        ],
      );
      if (!mounted) return;
      messenger
          .showSnackBar(const SnackBar(content: Text('Workout created.')));
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(const SnackBar(
          content: Text('Couldn’t create the workout. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create workout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Workout title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<WorkoutDifficulty>(
                  initialValue: _difficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    prefixIcon: Icon(Icons.speed),
                  ),
                  items: [
                    for (final d in WorkoutDifficulty.values)
                      DropdownMenuItem(
                          value: d, child: Text(_difficultyLabel(d))),
                  ],
                  onChanged: (v) =>
                      setState(() => _difficulty = v ?? _difficulty),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _equipment,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Equipment',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _focus,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Focus (optional)',
                    hintText: 'e.g. Core, Legs, Full body',
                    prefixIcon: Icon(Icons.center_focus_strong_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('Exercises', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < _exercises.length; i++)
                  _ExerciseRow(
                    index: i,
                    draft: _exercises[i],
                    canRemove: _exercises.length > 1,
                    onChangedSeconds: (s) =>
                        setState(() => _exercises[i].seconds = s),
                    onRemove: () => _removeExercise(i),
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_saving ? 'Creating…' : 'Create workout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.index,
    required this.draft,
    required this.canRemove,
    required this.onChangedSeconds,
    required this.onRemove,
  });

  final int index;
  final _ExerciseDraft draft;
  final bool canRemove;
  final ValueChanged<int> onChangedSeconds;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: draft.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Exercise ${index + 1}',
                      hintText: 'e.g. Jumping jacks',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.close),
                    onPressed: onRemove,
                  ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 4),
                const Icon(Icons.timer_outlined, size: 18),
                const SizedBox(width: 8),
                Text('${draft.seconds}s'),
                Expanded(
                  child: Slider(
                    value: draft.seconds.toDouble(),
                    min: 10,
                    max: 180,
                    divisions: 17,
                    label: '${draft.seconds}s',
                    onChanged: (v) => onChangedSeconds(v.round() ~/ 5 * 5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
