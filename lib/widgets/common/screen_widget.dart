import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_ui/screens/settings.dart';
import 'package:intl_ui/widgets/common/simple_shortcut.dart';
import 'package:intl_ui/widgets/dashboard/new_key_dialog.dart';

class ScreenWidget extends StatefulWidget {
  final Widget body;
  const ScreenWidget({
    required this.body,
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenWidget> createState() => _ScreenWidgetState();
}

class _ScreenWidgetState extends State<ScreenWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  _showAddNewDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => NewKeyDialog(
        initialValue: '',
        onDone: () {
          Navigator.pop(ctx);
        },
      ),
    );
  }

  _showSettingsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const Settings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleShortcut(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): () =>
            _showAddNewDialog(context),
        LogicalKeySet(LogicalKeyboardKey.escape): () =>
            FocusScope.of(context).unfocus(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.comma): () =>
            _showSettingsDialog(context),
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Focus(focusNode: _focusNode, child: widget.body),
            onTap: () => _focusNode.requestFocus(),
          ),
        ),
      ),
    );
  }
}
