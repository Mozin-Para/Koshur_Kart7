// lib/pages/map_address/confirm_delete_dialog.dart

import 'package:flutter/material.dart';
import 'address_model.dart';

/// A confirmation dialog before deleting an address.
class ConfirmDeleteDialog extends StatelessWidget {
  final Address address;

  const ConfirmDeleteDialog({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Address'),
      content: Text(
        'Remove this saved address?\n\n${address.line}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
