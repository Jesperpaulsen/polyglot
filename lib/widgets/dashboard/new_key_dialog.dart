import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/widgets/common/input.dart';

class NewKeyDialog extends ConsumerStatefulWidget {
  final String? initialValue;
  const NewKeyDialog({required this.initialValue, Key? key}) : super(key: key);

  @override
  ConsumerState<NewKeyDialog> createState() => _NewKeyDialogState();
}

class _NewKeyDialogState extends ConsumerState<NewKeyDialog> {
  String? _translationKey;
  var _translations = <String, String>{};

  @override
  void initState() {
    super.initState();
    _translationKey = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Add new translation key',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 20,
            ),
            Input(
              label: 'Translation key',
              value: widget.initialValue,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Translations:',
              style: TextStyle(fontSize: 15),
            ),
            [...(for ) ]
          ],
        ),
      ),
    );
  }
}
