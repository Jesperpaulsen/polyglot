import 'package:flutter/material.dart';
import 'package:polyglot/widgets/settings/general_settings.dart';
import 'package:polyglot/widgets/settings/translations_settings.dart';

enum SETTING_TYPES { GENERAL, TRANSLATIONS }

Map<SETTING_TYPES, SettingTab> settingTabs = {
  SETTING_TYPES.GENERAL: SettingTab(
    type: SETTING_TYPES.GENERAL,
    index: 0,
    widget: const GeneralSettings(),
    label: 'General',
  ),
  SETTING_TYPES.TRANSLATIONS: SettingTab(
    type: SETTING_TYPES.TRANSLATIONS,
    index: 1,
    widget: const TranslationsSettings(),
    label: 'Translations',
  )
};

class SettingTab {
  final SETTING_TYPES type;
  final int index;
  final String label;
  final Widget widget;

  SettingTab({
    required this.type,
    required this.index,
    required this.label,
    required this.widget,
  });
}
