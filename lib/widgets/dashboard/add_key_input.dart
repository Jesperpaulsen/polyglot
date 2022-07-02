import 'package:flutter/material.dart';
import 'package:intl_ui/widgets/common/button.dart';
import 'package:intl_ui/widgets/common/input.dart';
import 'package:intl_ui/widgets/dashboard/new_key_dialog.dart';

class AddKeyInput extends StatefulWidget {
  const AddKeyInput({Key? key}) : super(key: key);

  @override
  State<AddKeyInput> createState() => _AddKeyInputState();
}

class _AddKeyInputState extends State<AddKeyInput> {
  var translationKey = '';

  _showNeyKeyDialog() {
    return showDialog(
        context: context,
        builder: (ctx) => NewKeyDialog(
              initialValue: translationKey,
              onDone: () {
                setState(() {
                  translationKey = '';
                });
                Navigator.pop(ctx);
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 500,
            child: Input(
              value: translationKey,
              onChange: (value) {
                setState(() {
                  translationKey = value ?? '';
                });
              },
              label: 'Add new translation key',
              onSubmitted: _showNeyKeyDialog,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Button(
            onPressed: _showNeyKeyDialog,
            child: const Text(
              'Add key',
            ),
          ),
        ],
      ),
    );
  }
}
