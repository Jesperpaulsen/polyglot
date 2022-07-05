import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/services/config_handler.dart';
import 'package:intl_ui/widgets/common/button.dart';
import 'package:intl_ui/widgets/common/file_picker_input.dart';
import 'package:intl_ui/widgets/common/input.dart';

class GeneralSettings extends ConsumerStatefulWidget {
  const GeneralSettings({Key? key}) : super(key: key);

  @override
  ConsumerState<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends ConsumerState<GeneralSettings> {
  var path = ConfigHandler.instance.internalConfig?.internalProjectConfig?.path;
  var translationKeyInFiles =
      ConfigHandler.instance.projectConfig?.translationKeyInFiles;
  var translationApiKey = ConfigHandler
      .instance.internalConfig?.internalProjectConfig?.translateApiKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'General Settings',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        FilePickerInput(
          label: 'Project config path',
          path: ConfigHandler
              .instance.internalConfig?.internalProjectConfig?.path,
          onFilePicked: (newPath) {
            setState(() {
              path = newPath;
            });
          },
          type: PICKER_TYPE.FILE,
          allowedExtensions: const ['json'],
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 400,
          child: Input(
            label: 'Key used in translation files',
            value: ConfigHandler.instance.projectConfig?.translationKeyInFiles,
            onChange: (newTranslationKey) {
              setState(() {
                translationKeyInFiles = newTranslationKey;
              });
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 400,
          child: Input(
            label: 'Google Translation API key',
            value: ConfigHandler.instance.internalConfig?.internalProjectConfig
                ?.translateApiKey,
            onChange: (newTranslationApiKey) {
              setState(() {
                translationApiKey = newTranslationApiKey;
              });
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Button(
          child: const Text('Save'),
          onPressed: () {
            ConfigHandler.instance.internalConfig?.internalProjectConfig?.path =
                path!;
            ConfigHandler.instance.projectConfig?.translationKeyInFiles =
                translationKeyInFiles;
            ConfigHandler.instance.internalConfig?.internalProjectConfig
                ?.translateApiKey = translationApiKey;
            ConfigHandler.instance.saveInternalConfig();
          },
        )
      ],
    );
  }
}
