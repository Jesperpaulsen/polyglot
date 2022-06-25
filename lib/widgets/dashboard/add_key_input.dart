import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_ui/shortcuts/create_new.dart';
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

  _showAddNewDialog(BuildContext context) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN):
            const CreateNewIntent(),
      },
      child: Actions(
        dispatcher: LoggingActionDispatcher(),
        actions: <Type, Action<Intent>>{
          CreateNewIntent: CreateNewAction(
              openCreateNewDialog: () => _showAddNewDialog(context))
        },
        child: Focus(
          autofocus: true,
          child: Padding(
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
                        translationKey = value;
                      });
                    },
                    label: 'Add new translation key',
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Button(
                  child: const Text('Add key'),
                  onPressed: () => _showAddNewDialog(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    print('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}
