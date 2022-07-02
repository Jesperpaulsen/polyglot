import 'package:flutter/material.dart';
import 'package:intl_ui/widgets/settings/general_settings.dart';

enum SETTING_TYPES { GENERAL, TRANSLATIONS }

Map<SETTING_TYPES, SettingTab> settingTabs = {
  SETTING_TYPES.GENERAL: SettingTab(index: 0, widget: const GeneralSettings()),
  SETTING_TYPES.TRANSLATIONS: SettingTab(index: 1, widget: const Text('Hello'))
};

class SettingTab {
  final int index;
  final Widget widget;

  SettingTab({
    required this.index,
    required this.widget,
  });
}
