import 'dart:convert';
import 'dart:isolate';

import 'package:polyglot/services/translation_handler/correct_json_format.dart';
import 'package:polyglot/services/translation_handler/translation_handler.dart';

class BatchTextIsolateMessage {
  final SendPort port;
  final String apiKey;
  final Map<String, String?> masterTranslations;
  final Map<String, String?>? existingTranslations;
  final String sourceIntlCode;
  final String targetIntlCode;

  BatchTextIsolateMessage({
    required this.port,
    required this.apiKey,
    required this.masterTranslations,
    this.existingTranslations,
    required this.sourceIntlCode,
    required this.targetIntlCode,
  });
}

Future<void> translateBatchTextOnIsolate(
    BatchTextIsolateMessage message) async {
  final result = await _translateTextAsJson(message);
  message.port.send(result);
}

Future<Map<String, String?>> _translateTextAsJson(
    BatchTextIsolateMessage message) async {
  final client = TranslationClient(apiKey: message.apiKey);

  final Map<String, String?> resultMap = message.existingTranslations != null
      ? Map.from(message.existingTranslations!)
      : <String, String?>{};

  final masterTranslationEntriesAsList =
      message.masterTranslations.entries.toList();

  final parts =
      _createSubMapsToTranslate(masterTranslationEntriesAsList, resultMap);

  final parsedJsonFutures = <Future<void>>[];
  final allParts = <String, String?>{};

  for (final part in parts) {
    parsedJsonFutures.add(
      client
          .translateString(
            stringToTranslate: jsonEncode(part),
            sourceLanguage: message.sourceIntlCode,
            targetLanguage: message.targetIntlCode,
          )
          .then(_correctJsonWithSeparateIsolate)
          .then(
            (part) => allParts.addAll(
              part,
            ),
          ),
    );
  }

  await Future.wait(parsedJsonFutures);

  for (var i = 0; i < masterTranslationEntriesAsList.length; i++) {
    final key = masterTranslationEntriesAsList[i].key;

    final translatedString = allParts[i.toString()];

    if (translatedString != null) {
      resultMap[key] = translatedString;
    }
  }
  return resultMap;
}

Future<Map<String, String?>> _correctJsonWithSeparateIsolate(
  String? json,
) async {
  if (json == null) {
    return <String, String?>{};
  }

  final port = ReceivePort();
  Isolate.spawn<CorrectJsonFormatIsolateMessage>(
    correctJsonFormat,
    CorrectJsonFormatIsolateMessage(
      port: port.sendPort,
      json: json,
    ),
  );
  final result = await port.first as Map<String, String?>;
  return result;
}

List<Map<String, String>> _createSubMapsToTranslate(
  List<MapEntry<String, String?>> masterTranslationEntriesAsList,
  Map<String, String?> resultMap,
) {
  final parts = <Map<String, String>>[];
  var counter = 0;
  var currentMap = <String, String>{};

  for (var i = 0; i < masterTranslationEntriesAsList.length; i++) {
    final entry = masterTranslationEntriesAsList[i];

    if (resultMap.containsKey(entry.key)) {
      continue;
    }

    final stringToAdd = entry.value;
    if (stringToAdd == null) {
      continue;
    }

    if (counter < 200) {
      currentMap[i.toString()] = stringToAdd;
      counter += stringToAdd.length;
    } else {
      parts.add(currentMap);
      counter = 0;
      currentMap = <String, String>{};
    }
  }
  return parts;
}
