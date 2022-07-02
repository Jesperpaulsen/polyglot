import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/providers/translation_provider.dart';
import 'package:intl_ui/widgets/common/button.dart';
import 'package:intl_ui/widgets/common/input.dart';

class NewKeyDialog extends ConsumerStatefulWidget {
  final String initialValue;
  final VoidCallback onDone;
  const NewKeyDialog(
      {required this.initialValue, required this.onDone, Key? key})
      : super(key: key);

  @override
  ConsumerState<NewKeyDialog> createState() => _NewKeyDialogState();
}

class _NewKeyDialogState extends ConsumerState<NewKeyDialog> {
  late String _translationKey;
  final _translations = <String, String?>{};

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
        print('finished');
      } catch (e) {
        print(e);
      }
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = ref.read(TranslationProvider.provider).translations;
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
            for (var translation in translations.values)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Input(
                          value: _translations[translation.intlCode] ?? '',
                          label: translation.intlLanguageName ?? '',
                          onChange: (value) =>
                              _translations[translation.intlCode] = value,
                          onSubmitted: (_) => _storeTranslations(context),
                        ),
                      ),
                      if (!translation.isMaster)
                        IconButton(
                          icon: const Icon(
                            Icons.translate,
                          ),
                          onPressed: () {},
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
