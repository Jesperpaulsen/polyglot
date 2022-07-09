import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData iconData;
  final Color color;
  final VoidCallback? onPressed;

  const CustomIconButton({
    required this.iconData,
    required this.onPressed,
    this.color = Colors.orange,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: Icon(
          iconData,
          color: onPressed == null ? Colors.grey : color,
        ));
  }
}
