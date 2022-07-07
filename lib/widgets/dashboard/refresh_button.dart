import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polyglot/providers/translation_provider.dart';
import 'package:polyglot/services/config_handler.dart';

class RefreshButton extends ConsumerWidget {
  const RefreshButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshTranslations =
        ref.read(TranslationProvider.provider.notifier).reloadTranslations;
    return IconButton(
      onPressed: () async {
        await ConfigHandler.instance.refreshConfig();
        await refreshTranslations();
      },
      icon: const Icon(
        Icons.refresh,
      ),
    );
  }
}
