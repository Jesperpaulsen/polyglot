import 'package:flutter/material.dart';

class DropDownMenu<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? selectedValue;
  final void Function(T? selectedValue) onItemClicked;
  final Icon? icon;
  final String? hintText;

  const DropDownMenu({
    required this.items,
    this.selectedValue,
    required this.onItemClicked,
    required this.hintText,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      hint: Text(hintText ?? ''),
      isExpanded: true,
      items: items,
      onChanged: onItemClicked,
      value: selectedValue,
      icon: icon ?? const Icon(Icons.arrow_downward),
      underline: Container(
        height: 2,
        color: Colors.orange,
      ),
    );
  }
}
