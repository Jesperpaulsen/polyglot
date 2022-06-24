import 'package:flutter/material.dart';

class DeleteRowDialog extends StatelessWidget {
  final String translationKey;
  final Function({required bool shouldDelete}) deleteCallback;

  const DeleteRowDialog({
    required this.translationKey,
    required this.deleteCallback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Center(
        child: Text(
            'Are you sure you want to all corresponding translations for ${translationKey}?'),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => deleteCallback(shouldDelete: true),
          child: Text('yes'),
        ),
        ElevatedButton(
          onPressed: () => deleteCallback(shouldDelete: false),
          child: Text('no'),
        ),
      ],
    );
  }
}
