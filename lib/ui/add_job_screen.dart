/// The screen the app opens on, because logging is what happens in the bay.
///
/// Four fields. Date is today and pay type is customer until told otherwise —
/// both are one tap to change and neither costs a tap when they are right.
library;

import 'package:flutter/material.dart';

import '../data/logbook.dart';
import '../model/job.dart';
import '../model/writer.dart';
import 'writer_picker.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key, required this.logbook});

  final Logbook logbook;

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _repairOrder = TextEditingController();
  final _flagged = TextEditingController();
  final _actual = TextEditingController();

  PayType _payType = PayType.customer;
  DateTime _date = DateTime.now();
  int? _writerId;
  List<Writer> _writers = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWriters();
  }

  @override
  void dispose() {
    _repairOrder.dispose();
    _flagged.dispose();
    _actual.dispose();
    super.dispose();
  }

  Future<void> _loadWriters() async {
    final writers = await widget.logbook.writers();
    if (!mounted) return;
    setState(() {
      _writers = writers;
      _writerId ??= writers.isEmpty ? null : writers.first.id;
    });
  }

  Future<void> _save() async {
    final flagged = double.tryParse(_flagged.text.trim());
    if (_repairOrder.text.trim().isEmpty) {
      return setState(() => _error = 'Which repair order?');
    }
    if (flagged == null) {
      return setState(() => _error = 'Flagged hours, as a number');
    }
    if (_writerId == null) {
      return setState(() => _error = 'Add a writer first');
    }

    await widget.logbook.saveJob(Job(
      repairOrder: _repairOrder.text.trim(),
      date: _date,
      payType: _payType,
      writerId: _writerId!,
      flaggedHours: flagged,
      actualHours: double.tryParse(_actual.text.trim()),
    ));

    if (!mounted) return;
    _repairOrder.clear();
    _flagged.clear();
    _actual.clear();
    setState(() => _error = null);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Logged')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _repairOrder,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
              labelText: 'RO number', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _hours(_flagged, 'Flagged', autofocus: false)),
            const SizedBox(width: 12),
            Expanded(child: _hours(_actual, 'Actual')),
          ],
        ),
        const SizedBox(height: 12),
        WriterPicker(
          writers: _writers,
          selectedId: _writerId,
          logbook: widget.logbook,
          onChanged: (id) => setState(() => _writerId = id),
          onWritersChanged: _loadWriters,
        ),
        const SizedBox(height: 12),
        SegmentedButton<PayType>(
          segments: const [
            ButtonSegment(value: PayType.customer, label: Text('Cust')),
            ButtonSegment(value: PayType.warranty, label: Text('Warr')),
            ButtonSegment(value: PayType.internal, label: Text('Int')),
            ButtonSegment(value: PayType.recall, label: Text('Recall')),
          ],
          selected: {_payType},
          onSelectionChanged: (choice) =>
              setState(() => _payType = choice.first),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.event),
          label: Text(_isToday(_date) ? 'Today' : _readable(_date)),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
          child: const Text('Log it', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  Widget _hours(TextEditingController controller, String label,
          {bool autofocus = false}) =>
      TextField(
        controller: controller,
        autofocus: autofocus,
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
    if (chosen != null) setState(() => _date = chosen);
  }
}

bool _isToday(DateTime day) {
  final now = DateTime.now();
  return day.year == now.year && day.month == now.month && day.day == now.day;
}

String _readable(DateTime day) => '${day.day}/${day.month}';
