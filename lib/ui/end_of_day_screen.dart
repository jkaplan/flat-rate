/// Two figures, once a day. Scheduled is what the rota said; clocked is what
/// actually happened. Efficiency needs the first, proficiency the second, and
/// a wage-floor check would need the second as well.
library;

import 'package:flutter/material.dart';

import '../data/logbook.dart';
import '../model/work_day.dart';

class EndOfDayScreen extends StatefulWidget {
  const EndOfDayScreen({super.key, required this.logbook});

  final Logbook logbook;

  @override
  State<EndOfDayScreen> createState() => _EndOfDayScreenState();
}

class _EndOfDayScreenState extends State<EndOfDayScreen> {
  final _scheduled = TextEditingController();
  final _clocked = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scheduled.dispose();
    _clocked.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final days = await widget.logbook.daysBetween(_date, _date);
    if (!mounted || days.isEmpty) return;
    setState(() {
      _scheduled.text = _plain(days.first.scheduledHours);
      _clocked.text =
          days.first.clockedHours == null ? '' : _plain(days.first.clockedHours!);
    });
  }

  Future<void> _save() async {
    final scheduled = double.tryParse(_scheduled.text.trim());
    if (scheduled == null) return;

    await widget.logbook.saveDay(WorkDay(
      date: _date,
      scheduledHours: scheduled,
      clockedHours: double.tryParse(_clocked.text.trim()),
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Day saved')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.event),
          label: Text('${_date.day}/${_date.month}/${_date.year}'),
        ),
        const SizedBox(height: 16),
        _field(_scheduled, 'Hours I was scheduled'),
        const SizedBox(height: 12),
        _field(_clocked, 'Hours I was actually here'),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
          child: const Text('Save the day', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration:
            InputDecoration(labelText: label, border: const OutlineInputBorder()),
      );

  Future<void> _pickDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 1),
      lastDate: DateTime.now(),
    );
    if (chosen == null) return;
    setState(() => _date = chosen);
    await _load();
  }
}

String _plain(double hours) =>
    hours == hours.roundToDouble() ? hours.toStringAsFixed(0) : '$hours';
