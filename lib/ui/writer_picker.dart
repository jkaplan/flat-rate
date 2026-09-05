/// Picking the service writer in one tap, and adding a new one when the shop
/// hires. Free text was rejected because Dave and dave do not group.
library;

import 'package:flutter/material.dart';

import '../data/logbook.dart';
import '../model/writer.dart';

class WriterPicker extends StatelessWidget {
  const WriterPicker({
    super.key,
    required this.writers,
    required this.selectedId,
    required this.logbook,
    required this.onChanged,
    required this.onWritersChanged,
  });

  final List<Writer> writers;
  final int? selectedId;
  final Logbook logbook;
  final ValueChanged<int> onChanged;
  final VoidCallback onWritersChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final writer in writers)
          ChoiceChip(
            label: Text(writer.name),
            selected: writer.id == selectedId,
            onSelected: (_) => onChanged(writer.id),
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Writer'),
          onPressed: () => _addWriter(context),
        ),
      ],
    );
  }

  Future<void> _addWriter(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service writer'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      final id = await logbook.addWriter(name);
      onChanged(id);
      onWritersChanged();
    } on DuplicateWriterException catch (clash) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$clash')));
      }
    }
  }
}
