import 'package:flutter/material.dart';
import 'package:polyglot/widgets/settings/SETTING_TYPES.dart';

class SettingsTabs extends StatelessWidget {
  final int activeIndex;
  final void Function(SETTING_TYPES settingType) onChange;

  const SettingsTabs({
    required this.activeIndex,
    required this.onChange,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (final setting in settingTabs.values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChange(setting.type),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: setting.index == activeIndex
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ),
                  child: Text(setting.label),
                ),
              ),
            ),
          )
      ],
    );
  }
}
