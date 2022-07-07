import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:polyglot/models/language_config.dart';
import 'package:polyglot/models/translation_manager.dart';
import 'package:polyglot/services/config_handler.dart';

class TranslationLoad {
  final Set<String> translationKeys;
  final Map<String, String?> translations;

  TranslationLoad({required this.translationKeys, required this.translations});
}

class IsolateMessage {
  final SendPort port;
  final String path;
  final String? translationKeyInFiles;

  IsolateMessage({
    required this.port,
    required this.path,
    this.translationKeyInFiles,
  });
}

class AllTranslationsLoadResult {
  String? masterIntlCode;
  final allTranslationKeys = <String>{};
  final translationsPerCountry = <String, TranslationManager>{};
}

class TranslationsLoaderIsolate {
  Future<AllTranslationsLoadResult> loadTranslations() async {
    final loadResult = AllTranslationsLoadResult();
    final futures = <Future<void>>[];
    for (final languageConfig
        in ConfigHandler.instance.projectConfig?.languageConfigs.values ??
            <LanguageConfig>[]) {
      futures.add(
        _loadTranslationFileWithSeparateIsolate(languageConfig)
            .then((translationLoad) {
          if (languageConfig.isMaster && loadResult.masterIntlCode == null) {
            loadResult.masterIntlCode = languageConfig.languageCode;
          }
          loadResult.allTranslationKeys.addAll(translationLoad.translationKeys);
          loadResult.translationsPerCountry[languageConfig.languageCode] =
              TranslationManager(
            intlCode: languageConfig.languageCode,
            translations: translationLoad.translations,
            isMaster: languageConfig.isMaster,
          );
        }),
      );
    }
    await Future.wait(futures);
    return loadResult;
  }

  Future<TranslationLoad> _loadTranslationFileWithSeparateIsolate(
    LanguageConfig config,
  ) async {
    final path = File.fromUri(
      Uri(
          path:
              '${ConfigHandler.instance.translationDirectory}/${config.pathToi18nFile}'),
    ).path;

    final port = ReceivePort();
    final translationKeyInFiles =
        ConfigHandler.instance.projectConfig?.translationKeyInFiles;

    Isolate.spawn<IsolateMessage>(
      _readFileOnIsolate,
      IsolateMessage(
        port: port.sendPort,
        path: path,
        translationKeyInFiles: translationKeyInFiles,
      ),
    );
    return await port.first as TranslationLoad;
  }

  Future<void> _readFileOnIsolate(IsolateMessage message) async {
    final port = message.port;
    final fileName = message.path;
    final translationKeyInFiles = message.translationKeyInFiles;

    final translationKeys = <String>{};
    final translations = <String, String>{};
    try {
      final fileData = await File(fileName).readAsString();
      var json = jsonDecode(fileData);

      if (translationKeyInFiles != null && translationKeyInFiles.isNotEmpty) {
        json = json[translationKeyInFiles];
      }

      if (json == null) {
        port.send(TranslationLoad(
            translationKeys: <String>{}, translations: <String, String>{}));
        return;
      }

      for (final entry in json.entries) {
        final key = entry.key;
        final value = entry.value;
        translationKeys.add(key);
        translations[key] = value;
      }

      port.send(
        TranslationLoad(
          translationKeys: translationKeys,
          translations: translations,
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
