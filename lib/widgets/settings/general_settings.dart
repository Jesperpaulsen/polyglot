import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/providers/translation_provider.dart';
import 'package:intl_ui/services/config_handler.dart';
import 'package:intl_ui/services/debouncer.dart';
import 'package:intl_ui/widgets/common/file_picker_input.dart';
import 'package:intl_ui/widgets/common/input.dart';

class GeneralSettings extends ConsumerStatefulWidget {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  ConsumerState<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends ConsumerState<GeneralSettings> {
  late final VoidCallback _reloadTranslations;
  late final Debouncer debouncer;

  @override
  void initState() {
    super.initState();
    _reloadTranslations =
        ref.read(TranslationProvider.provider.notifier).reloadTranslations;
    debouncer = Debouncer(
      callbackFn: _reloadTranslations,
      timeout: const Duration(
        milliseconds: 700,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    debouncer.cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
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
            debouncer.changeHappened();
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
          onChange: (newTranslationKey) {
            ConfigHandler.instance.projectConfig?.translationKeyInFiles =
                newTranslationKey;
            ConfigHandler.instance.saveProjectConfig();
            debouncer.changeHappened();
          },
        )
      ],
    );
  }
}
