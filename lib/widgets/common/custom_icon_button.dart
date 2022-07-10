import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final String? tooltipMessage;
  final IconData iconData;
  final Color color;
  final VoidCallback? onPressed;

  const CustomIconButton({
    required this.iconData,
    required this.onPressed,
    this.tooltipMessage,
    this.color = Colors.orange,
    Key? key,
  }) : super(key: key);

  _getIconButton() {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        iconData,
        color: onPressed == null ? Colors.grey : color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return tooltipMessage != null
        ? Tooltip(
            message: tooltipMessage,
            child: _getIconButton(),
          )
        : _getIconButton();
  }
}
