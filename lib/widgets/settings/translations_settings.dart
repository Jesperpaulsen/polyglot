import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/providers/translation_provider.dart';
import 'package:intl_ui/services/config_handler.dart';
import 'package:intl_ui/widgets/common/button.dart';
import 'package:intl_ui/widgets/common/input.dart';

class TranslationsSettings extends ConsumerStatefulWidget {
  const TranslationsSettings({Key? key}) : super(key: key);

  @override
  ConsumerState<TranslationsSettings> createState() =>
      _TranslationsSettingsState();
}

class _TranslationsSettingsState extends ConsumerState<TranslationsSettings> {
  String? intlCode;
  String? fileName;
  var intlCodeToName = <String, String>{};

  @override
  void initState() {
    super.initState();
    initializeKeys();
  }

  initializeKeys() async {
    final json =
        await rootBundle.loadString('assets/internalization_languages.json');
    intlCodeToName = Map<String, String>.from(jsonDecode(json));
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(TranslationProvider.provider);
    final translationProvider = ref.read(TranslationProvider.provider.notifier);
    return Container(
      child: Column(
        children: [
          const Text(
            'Translations',
            style: TextStyle(fontSize: 24),
          ),
          ...[
            for (final translation in translationState.translations.values)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(translation.intlLanguageName ?? ''),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      translation.intlCode,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (translation.isMaster)
                      const Text(
                        'Master',
                        style: TextStyle(color: Colors.teal),
                      )
                    else
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.translate),
                      ),
                  ],
                ),
              )
          ],
          const SizedBox(
            height: 40,
          ),
          Row(
            children: [
              SizedBox(
                width: 250,
                child: Autocomplete<String>(
                  fieldViewBuilder: ((context, textEditingController, focusNode,
                          onFieldSubmitted) =>
                      Input(
                        controller: textEditingController,
                        onSubmitted: (_) => onFieldSubmitted(),
                      )),
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return intlCodeToName.values.where(
                      (option) => option.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 250,
                child: Input(
                  label: 'Translation file name',
                  onChange: (value) => setState(() {
                    fileName = value;
                  }),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Button(
                onPressed: intlCode != null && fileName != null
                    ? () async {
                        if (!fileName!.endsWith('.json')) {
                          fileName = '$fileName.json';
                        }
                        await ConfigHandler.instance
                            .addLanguageToProject(intlCode!, fileName!);

                        translationProvider.reloadTranslations();
                      }
                    : null,
                child: const Text('Add language'),
              )
            ],
          )
        ],
      ),
    );
  }
}
