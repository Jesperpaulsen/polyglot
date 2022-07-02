import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/providers/translation_provider.dart';
import 'package:intl_ui/services/config_handler.dart';
import 'package:intl_ui/widgets/common/file_picker_input.dart';
import 'package:intl_ui/widgets/common/input.dart';

class GeneralSettings extends ConsumerWidget {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reloadTranslations =
        ref.read(TranslationProvider.provider.notifier).reloadTranslations;
    return Column(
      children: [
        const Text('Settings'),
        const SizedBox(height: 20),
        FilePickerInput(
          label: 'Project config path',
          path: ConfigHandler.instance.internalConfig?.projectConfigPath,
          onFilePicked: (path) {
            if (path == null) return;
            ConfigHandler.instance.changePathToProjectConfigFile(path);
            reloadTranslations();
          },
          type: PICKER_TYPE.FILE,
          allowedExtensions: const ['json'],
        ),
        const SizedBox(
          height: 10,
        ),
        Input(
          label: 'Key used in translation files',
          value: ConfigHandler.instance.projectConfig?.translationKeyInFiles,
          onSubmitted: (newTranslationKey) {
            ConfigHandler.instance.projectConfig?.translationKeyInFiles =
                newTranslationKey;
            ConfigHandler.instance.saveProjectConfig();
            reloadTranslations();
          },
        )
      ],
    );
  }
}
