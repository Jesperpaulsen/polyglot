import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleShortcut extends StatelessWidget {
  final Map<ShortcutActivator, VoidCallback> bindings;
  final Widget child;
  final bool autoFocus;

  const SimpleShortcut({
    Key? key,
    required this.bindings,
    required this.child,
    this.autoFocus = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: autoFocus,
      onKey: (FocusNode node, RawKeyEvent event) {
        KeyEventResult result = KeyEventResult.ignored;
        for (final ShortcutActivator activator in bindings.keys) {
          if (activator.accepts(event, RawKeyboard.instance)) {
            bindings[activator]!.call();
            result = KeyEventResult.handled;
          }
        }
        return result;
      },
      child: child,
    );
  }
}
