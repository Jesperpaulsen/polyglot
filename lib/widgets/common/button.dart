import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final void Function()? onPressed;
  final Widget child;
  ButtonStyle? style;

  Button({
    this.onPressed,
    color = Colors.blue,
    required this.child,
    Key? key,
  }) : super(key: key) {
    if (onPressed != null) {
      style = ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}
