import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polyglot/providers/translation_provider.dart';
import 'package:polyglot/services/config_handler.dart';
import 'package:polyglot/widgets/common/button.dart';
import 'package:polyglot/widgets/common/custom_icon_button.dart';
import 'package:polyglot/widgets/common/input.dart';

class AutocompleteOption {
  final String intlCode;
  final String name;
  final String label;

  AutocompleteOption({
    required this.intlCode,
    required this.name,
  }) : label = '$intlCode: $name';
}

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

  Future<void> addLanguage() async {
    if (intlCode == null || fileName == null) {
      return;
    }
    if (!fileName!.endsWith('.json')) {
      fileName = '$fileName.json';
    }
    await ConfigHandler.instance.addLanguageToProject(intlCode!, fileName!);

    await ref.read(TranslationProvider.provider.notifier).reloadTranslations();
    setState(() {
      intlCode = '';
      fileName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(TranslationProvider.provider);
    final translationProvider = ref.read(TranslationProvider.provider.notifier);
    return Column(
      children: [
        const Text(
          'Translations',
          style: TextStyle(fontSize: 24),
        ),
        if (translationState.loading)
          const Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          for (final managerKey in translationState.sortedManagersKeys)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(translationState
                          .translations[managerKey]!.intlLanguageName ??
                      ''),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    translationState.translations[managerKey]!.intlCode,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (translationState.translations[managerKey]!.isMaster)
                    const Text(
                      'Master',
                      style: TextStyle(color: Colors.orange),
                    )
                  else
                    CustomIconButton(
                      tooltipMessage:
                          'Translate missing keys for ${translationState.translations[managerKey]!.intlLanguageName}',
                      onPressed: () => translationProvider.batchTranslation(
                        targetIntlCode: managerKey,
                      ),
                      iconData: Icons.translate,
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
              child: Autocomplete<AutocompleteOption>(
                onSelected: (value) => setState(() {
                  intlCode = value.intlCode;
                }),
                fieldViewBuilder: ((context, textEditingController, focusNode,
                        onFieldSubmitted) =>
                    Input(
                      label: 'Select language',
                      controller: textEditingController,
                      onSubmitted: (_) => onFieldSubmitted(),
                      focusNode: focusNode,
                    )),
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<AutocompleteOption>.empty();
                  }
                  return intlCodeToName.entries
                      .where(
                        (option) => option.value.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                      )
                      .map((e) =>
                          AutocompleteOption(intlCode: e.key, name: e.value));
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 600), //RELEVANT CHANGE: added maxWidth
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return InkWell(
                              onTap: () {
                                onSelected(option);
                              },
                              child: Builder(builder: (BuildContext context) {
                                final bool highlight =
                                    AutocompleteHighlightedOption.of(context) ==
                                        index;
                                if (highlight) {
                                  SchedulerBinding.instance
                                      .addPostFrameCallback(
                                          (Duration timeStamp) {
                                    Scrollable.ensureVisible(context,
                                        alignment: 0.5);
                                  });
                                }
                                return Container(
                                  color: highlight
                                      ? Theme.of(context).focusColor
                                      : null,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(option.label),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                displayStringForOption: (option) => option.label,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 250,
              child: Input(
                label: 'Translation file name',
                onChange: (value) => setState(
                  () {
                    fileName = value;
                  },
                ),
                onSubmitted: (_) => addLanguage(),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Button(
              onPressed: intlCode != null && fileName != null
                  ? () => addLanguage()
                  : null,
              label: 'Add language',
            )
          ],
        )
      ],
    );
  }
}
