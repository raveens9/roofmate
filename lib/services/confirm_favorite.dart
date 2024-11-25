import 'package:flutter/material.dart';

class ConfirmFavoriteDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ConfirmFavoriteDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: const Text('Are you sure you want to delete this listing?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close the dialog
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm(); // Trigger the confirm callback
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
