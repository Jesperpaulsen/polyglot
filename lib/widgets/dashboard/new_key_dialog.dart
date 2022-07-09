import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polyglot/providers/translation_provider.dart';
import 'package:polyglot/services/translation_handler/translation_handler.dart';
import 'package:polyglot/widgets/common/button.dart';
import 'package:polyglot/widgets/common/input.dart';

class NewKeyDialog extends ConsumerStatefulWidget {
  final String initialValue;
  final VoidCallback onDone;
  const NewKeyDialog({
    required this.initialValue,
    required this.onDone,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<NewKeyDialog> createState() => _NewKeyDialogState();
}

class _NewKeyDialogState extends ConsumerState<NewKeyDialog> {
  late String _translationKey;
  var _translations = <String, String?>{};
  var autoFilledTranslations = <String>{};

  @override
  void initState() {
    super.initState();
    _translationKey = widget.initialValue;
  }

  Future<void> _storeTranslations(BuildContext context) async {
    if (_translationKey.isNotEmpty) {
      try {
        await ref.read(TranslationProvider.provider.notifier).addTranslations(
            translationKey: _translationKey, translations: _translations);
      } catch (e) {
        print(e);
      }
      widget.onDone();
    }
  }

  void findTranslationsForKey(String? translationKey) {
    final translationState = ref.read(TranslationProvider.provider);

    if (!translationState.translationKeys.contains(translationKey)) {
      return;
    }

    final translationsForKey = <String, String?>{};

    for (final translation in translationState.translations.values) {
      final currentTranslation = _translations[translation.intlCode];

      if (currentTranslation != null &&
          currentTranslation.isNotEmpty &&
          !autoFilledTranslations.contains(translation.intlCode)) {
        translationsForKey[translation.intlCode] = currentTranslation;
        continue;
      }
      final existingTranslation = translation.translations[translationKey];
      translationsForKey[translation.intlCode] = existingTranslation;
      autoFilledTranslations.add(translation.intlCode);
    }

    setState(() {
      _translations = translationsForKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    final translations = ref.read(TranslationProvider.provider).translations;
    final sortedManagersKeys =
        ref.read(TranslationProvider.provider).sortedManagersKeys;
    return AlertDialog(
      content: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Add new translation key',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            Input(
              autofocus: true,
              label: 'Translation key',
              value: widget.initialValue,
              onChange: (value) {
                findTranslationsForKey(value);
                setState(() {
                  _translationKey = value ?? '';
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Translations:',
              style: TextStyle(fontSize: 15),
            ),
            for (final managerKey in sortedManagersKeys)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Input(
                          value: _translations[managerKey] ?? '',
                          label:
                              translations[managerKey]!.intlLanguageName ?? '',
                          onChange: (value) {
                            _translations[managerKey] = value;
                            autoFilledTranslations.remove(managerKey);
                          },
                          onSubmitted: (_) => _storeTranslations(context),
                        ),
                      ),
                      if (!translations[managerKey]!.isMaster)
                        IconButton(
                          icon: const Icon(
                            Icons.translate,
                          ),
                          onPressed: () async {
                            final result = await TranslationHandler.instance
                                .translateString(
                              stringToTranslate: _translations[
                                      translations.values.first.intlCode] ??
                                  '',
                              sourceIntlCode:
                                  translations.values.first.intlCode,
                              targetIntlCode: managerKey,
                            );

                            setState(() {
                              _translations[managerKey] = result;
                            });
                          },
                          iconSize: 18,
                          color: Colors.blue,
                          padding: const EdgeInsets.all(0),
                        ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
      actions: [
        Button(
          onPressed: _translationKey.isEmpty
              ? null
              : () => _storeTranslations(context),
          child: const Text('Save'),
        )
      ],
    );
  }
}
