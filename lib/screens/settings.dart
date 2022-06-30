import 'package:flutter/material.dart';
import 'package:intl_ui/widgets/settings/general_settings.dart';
import 'package:intl_ui/widgets/settings/settings_tabs.dart';
import 'package:intl_ui/widgets/settings/translations_settings.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
          height: 400,
          width: 800,
          child: Column(
            children: [
              SettingsTabs(),
              Stack(
                children: [GeneralSettings(), TranslationsSettings()],
              )
            ],
          )),
    );
  }
}
