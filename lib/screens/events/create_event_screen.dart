import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/content_state.dart';

/// Lets a signed-in student create a new intramural event. The new event is
/// pushed to the Realtime Database so every other student sees it.
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _venue = TextEditingController();
  final _description = TextEditingController();

  static const _sports = [
    'Running',
    'Football',
    'Basketball',
    'Badminton',
    'Volleyball',
    'Futsal',
    'Tennis',
    'Cycling',
    'Yoga',
    'Other',
  ];
  String _sport = _sports.first;
  DateTime _start = DateTime.now().add(const Duration(days: 1, hours: 1));
  int _capacity = 20;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _venue.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _start.isBefore(now) ? now : _start,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time == null || !mounted) return;
    setState(() {
      _start =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final content = context.read<ContentState>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      await content.createEvent(
        title: _title.text,
        sport: _sport,
        startTime: _start,
        venue: _venue.text,
        capacity: _capacity,
        description: _description.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(
          const SnackBar(content: Text('Event created.')));
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
          const SnackBar(content: Text('Couldn’t create the event. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE, d MMM yyyy • h:mm a').format(_start);

    return Scaffold(
      appBar: AppBar(title: const Text('Create event')),
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
                    labelText: 'Event title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _sport,
                  decoration: const InputDecoration(
                    labelText: 'Sport',
                    prefixIcon: Icon(Icons.sports),
                  ),
                  items: [
                    for (final s in _sports)
                      DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged: (v) => setState(() => _sport = v ?? _sport),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Date & time'),
                    subtitle: Text(dateLabel),
                    trailing: const Icon(Icons.edit_calendar_outlined),
                    onTap: _pickDateTime,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _venue,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Venue',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a venue'
                      : null,
                ),
                const SizedBox(height: 24),
                Text('Capacity: $_capacity players',
                    style: theme.textTheme.titleMedium),
                Slider(
                  value: _capacity.toDouble(),
                  min: 2,
                  max: 50,
                  divisions: 48,
                  label: '$_capacity',
                  onChanged: (v) => setState(() => _capacity = v.round()),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes),
                  ),
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
                  label: Text(_saving ? 'Creating…' : 'Create event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
