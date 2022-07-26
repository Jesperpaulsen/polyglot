import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polyglot/models/casing.dart';
import 'package:polyglot/providers/translation_provider.dart';
import 'package:polyglot/services/config_handler.dart';
import 'package:polyglot/services/translation_handler/translation_handler.dart';
import 'package:polyglot/widgets/common/button.dart';
import 'package:polyglot/widgets/common/dropdown.dart';
import 'package:polyglot/widgets/common/file_picker_input.dart';
import 'package:polyglot/widgets/common/input.dart';

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
  var casing = ConfigHandler.instance.projectConfig?.casing;

  @override
  Widget build(BuildContext context) {
    final translationProvider = ref.read(TranslationProvider.provider.notifier);

    return Center(
      child: Column(
        children: [
          const Text(
            'General Settings',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 400,
            child: FilePickerInput(
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
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 400,
            child: Input(
              label:
                  'Root translation key used in translation files (Optional)',
              value:
                  ConfigHandler.instance.projectConfig?.translationKeyInFiles,
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
              value: ConfigHandler.instance.internalConfig
                  ?.internalProjectConfig?.translateApiKey,
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
          DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white10,
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Casing used in files:',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(
                    width: 385,
                    child: DropDownMenu<Casing>(
                        hintText: 'Casing type',
                        selectedValue: casing,
                        onItemClicked: (newCasing) {
                          if (newCasing != null) {
                            setState(() {
                              casing = newCasing;
                            });
                          }
                        },
                        items: casingsMap.values
                            .map(
                              (casing) => DropdownMenuItem(
                                value: casing,
                                child: Text(casing.title),
                              ),
                            )
                            .toList()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Button(
            label: 'Save',
            onPressed: () async {
              ConfigHandler
                  .instance.internalConfig?.internalProjectConfig?.path = path!;
              ConfigHandler.instance.projectConfig?.translationKeyInFiles =
                  translationKeyInFiles;
              ConfigHandler.instance.internalConfig?.internalProjectConfig
                  ?.translateApiKey = translationApiKey;

              await ConfigHandler.instance.saveInternalConfig();
              await ConfigHandler.instance.updateProjectCasing(casing);
              await translationProvider.reloadTranslations();
              TranslationHandler.instance.initialize();
            },
          )
        ],
      ),
    );
  }
}
