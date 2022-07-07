import 'dart:io';
import 'dart:isolate';

import 'package:polyglot/models/language_config.dart';
import 'package:polyglot/models/translation_manager.dart';
import 'package:polyglot/services/config_handler.dart';
import 'package:polyglot/utils/prettyJsonString.dart';

class IsolateMessage {
  final SendPort port;
  final String path;
  final String? translationKeyInFiles;
  final Map<String, String?> translations;

  IsolateMessage({
    required this.port,
    required this.path,
    required this.translations,
    this.translationKeyInFiles,
  });
}

class TranslationWriterIsolate {
  Future<void> addTranslations({
    required String translationKey,
    required Map<String, String?> translations,
    required Map<String, TranslationManager> translationManagers,
  }) async {
    final futures = <Future<void>>[];
    for (final translationEntry in translations.entries) {
      if (translationEntry.value == null) {
        continue;
      }
      final intlCode = translationEntry.key;
      final translation = translationEntry.value;

      final manager = translationManagers[intlCode];

      if (manager == null) {
        throw Exception(
            '[TranslationWriterIsolate] No translation manager matching translation code $intlCode');
      }
      final config =
          ConfigHandler.instance.projectConfig?.languageConfigs[intlCode];

      if (config == null) {
        throw Exception(
            '[TranslationWriterIsolate] No translation config matching translation code $intlCode');
      }

      manager.translations[translationKey] = translation;
      futures
          .add(sortAndWriteTranslationFileWithSeparateIsolate(config, manager));
    }
    await Future.wait(futures);
  }

  Future<void> updateKeyInAllTranslationFiles({
    required String oldTranslationKey,
    required String? newTranslationKey,
    required Map<String, TranslationManager> translationManagers,
  }) async {
    final allConfigs = ConfigHandler.instance.projectConfig?.languageConfigs;
    if (allConfigs == null) {
      return;
    }

    final futures = <Future<void>>[];

    for (final config in allConfigs.values) {
      final manager = translationManagers[config.languageCode];
      if (manager == null) {
        print(
            '[TranslationWriterIsolate] No translations manager found for ${config.languageCode}');
        return;
      }

      final oldTranslation = manager.translations[oldTranslationKey];
      manager.translations.remove(oldTranslationKey);
      if (newTranslationKey != null) {
        manager.translations[newTranslationKey] = oldTranslation;
      }

      futures
          .add(sortAndWriteTranslationFileWithSeparateIsolate(config, manager));
    }
    await Future.wait(futures);
  }

  Future<void> sortAndWriteTranslationFileWithSeparateIsolate(
    LanguageConfig config,
    TranslationManager manager,
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
      _writeAndSortFileOnIsolate,
      IsolateMessage(
        port: port.sendPort,
        path: path,
        translationKeyInFiles: translationKeyInFiles,
        translations: manager.translations,
      ),
    );
    await port.first;
    return;
  }

  Future<void> _writeAndSortFileOnIsolate(IsolateMessage message) async {
    final port = message.port;
    final fileName = message.path;
    final translationKeyInFiles = message.translationKeyInFiles;
    final translations = message.translations;

    try {
      final sortedTranslations = translations.entries.toList()
        ..sort((translationA, translationB) =>
            translationA.key.compareTo(translationB.key));

      final result = <String, String?>{};

      for (final sortedTranslation in sortedTranslations) {
        result[sortedTranslation.key] = sortedTranslation.value;
      }

      var json = <dynamic, dynamic>{};
      if (translationKeyInFiles != null) {
        json[translationKeyInFiles] = result;
      } else {
        json = result;
      }
      final encodedJson = getPrettyJSONString(json);
      await File(fileName).writeAsString(encodedJson);
      port.send(Null);
    } catch (e) {
      print(e);
    }
  }
}
