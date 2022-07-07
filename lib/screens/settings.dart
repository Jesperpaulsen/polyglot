import 'package:flutter/material.dart';
import 'package:polyglot/widgets/settings/SETTING_TYPES.dart';
import 'package:polyglot/widgets/settings/settings_tabs.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var _activeTab = settingTabs[SETTING_TYPES.GENERAL]!;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
          height: 400,
          width: 800,
          child: Column(
            children: [
              SettingsTabs(
                activeIndex: _activeTab.index,
                onChange: (type) {
                  final newTab = settingTabs[type];
                  setState(() {
                    _activeTab = newTab!;
                  });
                },
              ),
              IndexedStack(
                index: _activeTab.index,
                children: [
                  for (final setting in settingTabs.values) setting.widget
                ],
              )
            ],
          )),
    );
  }
}
