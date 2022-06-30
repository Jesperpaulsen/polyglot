import 'package:flutter/material.dart';

class SettingsTabs extends StatelessWidget {
  const SettingsTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [Text('General'), Text('Translations')],
    );
  }
}
