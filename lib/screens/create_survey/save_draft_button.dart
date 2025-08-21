import 'package:flutter/material.dart';

class SaveDraftButton extends StatelessWidget {
  final VoidCallback onSave;
  final bool enabled;

  const SaveDraftButton({
    super.key,
    required this.onSave,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: enabled ? onSave : null,
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text(
        'Save Draft',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}