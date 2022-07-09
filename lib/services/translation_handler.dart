import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:polyglot/services/config_handler.dart';

class TranslationClient {
  final String apiKey;
  final _dio = Dio();

  TranslationClient({required this.apiKey}) {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: _onRequestInterceptor));
  }

  _onRequestInterceptor(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    options.path += '?key=$apiKey';
    return handler.next(options);
  }

  Future<String?> translateString({
    required String stringToTranslate,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final res = await _dio.post(
          'https://translation.googleapis.com/language/translate/v2',
          data: {
            'q': stringToTranslate,
            'source': sourceLanguage,
            'target': targetLanguage,
            'format': 'text'
          });
      return res.data['data']['translations'][0]['translatedText'];
    } on DioError catch (e) {
      print(e.response?.data['data']);
      print(e);
    }
    return null;
  }
}

class TranslationHandler {
  TranslationClient? _client;

  TranslationHandler._privateConstructor() {
    initialize();
  }

  static final instance = TranslationHandler._privateConstructor();

  TranslationClient? get client {
    return _client;
  }

  initialize() {
    if (ConfigHandler
            .instance.internalConfig?.internalProjectConfig?.translateApiKey !=
        null) {
      _client = TranslationClient(
        apiKey: ConfigHandler
            .instance.internalConfig!.internalProjectConfig!.translateApiKey!,
      );
    }
  }

  Future<String?> translateString({
    required String stringToTranslate,
    required String sourceIntlCode,
    required String targetIntlCode,
  }) async {
    if (_client == null) {
      throw Exception('Translation client is not defined');
    }

    final translatedString = await _client!.translateString(
      stringToTranslate: stringToTranslate,
      sourceLanguage: sourceIntlCode,
      targetLanguage: targetIntlCode,
    );
    return translatedString;
  }

  Future<Map<String, String?>> translateBatch({
    required Map<String, String?> masterTranslations,
    Map<String, String?>? existingTranslations,
    required String sourceIntlCode,
    required String targetIntlCode,
  }) async {
    if (ConfigHandler
            .instance.internalConfig?.internalProjectConfig?.translateApiKey ==
        null) {
      return <String, String?>{};
    }

    final port = ReceivePort();
    final apiKey = ConfigHandler
        .instance.internalConfig!.internalProjectConfig!.translateApiKey!;

    Isolate.spawn<IsolateMessage>(
      _translateBatchTextOnIsolate,
      IsolateMessage(
        port: port.sendPort,
        apiKey: apiKey,
        masterTranslations: masterTranslations,
        existingTranslations: existingTranslations,
        sourceIntlCode: sourceIntlCode,
        targetIntlCode: targetIntlCode,
      ),
    );

    return await port.first as Map<String, String?>;
  }
}

class IsolateMessage {
  final SendPort port;
  final String apiKey;
  final Map<String, String?> masterTranslations;
  final Map<String, String?>? existingTranslations;
  final String sourceIntlCode;
  final String targetIntlCode;

  IsolateMessage({
    required this.port,
    required this.apiKey,
    required this.masterTranslations,
    this.existingTranslations,
    required this.sourceIntlCode,
    required this.targetIntlCode,
  });
}

Future<void> _translateBatchTextOnIsolate(IsolateMessage message) async {
  final client = TranslationClient(apiKey: message.apiKey);

  print(message.existingTranslations);

  final result = translateTextAsJson(message);

  message.port.send(result);
}

/*
* Trying to solve it with json, but not ideal because translate tend to miss commas
*
* */

Future<Map<String, String?>> translateTextAsJson(IsolateMessage message) async {
  final client = TranslationClient(apiKey: message.apiKey);

  final parts = <Map<String, String>>[];
  var counter = 0;
  var currentMap = <String, String>{};
  final Map<String, String?> resultMap = message.existingTranslations != null
      ? Map.from(message.existingTranslations!)
      : <String, String?>{};

  final masterTranslationEntriesAsList =
      message.masterTranslations.entries.toList();

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

  final futures = <Future<String?>>[];

  for (final part in parts) {
    futures.add(client.translateString(
      stringToTranslate: jsonEncode(part),
      sourceLanguage: message.sourceIntlCode,
      targetLanguage: message.targetIntlCode,
    ));
  }

  final results = await Future.wait(futures);

  final allParts = <String, String>{};

  for (final result in results) {
    if (result == null) continue;
    final fixedJsonString = addMissingCommasToJsonString(result);

    print(fixedJsonString);

    allParts.addAll(Map<String, String>.from(jsonDecode(result)));
  }

  for (var i = 0; i < masterTranslationEntriesAsList.length; i++) {
    final key = masterTranslationEntriesAsList[i].key;

    final translatedString = allParts[i];

    if (translatedString != null) {
      resultMap[key] = allParts[i];
    }
  }

  return resultMap;
}

String addMissingCommasToJsonString(String json) {
  var res = '';

  var ruleIndex = 0;

  final rules = <bool Function(String, String, String)>[
    (previous, current, next) =>
        previous == '{' || previous == ',' || previous == ' ' && current != ':',
    (previous, current, next) => current == '"' && next != '"' && next != ",",
    (previous, current, next) => current == '"' && next == ":",
    (previous, current, next) => current == '"' && next != '"',
  ];

  bool finalRule(String previous, String current, String next) {
    if (previous == ":" || previous == ",") {
      return false;
    }
    if (current == '"' && next != ',' && next != '}') {
      print('final');
      ruleIndex = 0;
      return true;
    } else if (current == '"' && next == ',') {
      ruleIndex = 0;
      return false;
    }
    return false;
  }

  for (var i = 1; i < json.length - 1; i++) {
    final previous = json[i - 1];
    final current = json[i];
    final next = json[i + 1];

    if (ruleIndex == rules.length - 1) {
      final result = finalRule(previous, current, next);
      if (result) {
        res += "$current,";
      } else {
        res += current;
      }
    } else {
      final result = rules[ruleIndex](previous, current, next);
      if (result) {
        ruleIndex++;
        print(ruleIndex);
      }
      res += current;
    }
  }

  return res;
}

/*
* The idea is to build up longer strings encoded with an encoder, translate it and then decode it.
* The problem is that Google Translate API tends to break up the encoder in different ways, making it difficult to decode it again.
* */

Future<Map<String, String?>> translateTextWithEncoder(
    IsolateMessage message) async {
  final client = TranslationClient(apiKey: message.apiKey);
  const encoder = '©™©';
  final parts = <String>[];
  var counter = 0;
  var currentString = '';
  final Map<String, String?> resultMap = message.existingTranslations != null
      ? Map.from(message.existingTranslations!)
      : <String, String?>{};

  final masterTranslationEntriesAsList =
      message.masterTranslations.entries.toList();

  for (final entry in masterTranslationEntriesAsList) {
    if (resultMap.containsKey(entry.key)) {
      continue;
    }

    if (counter < 2000) {
      final stringToAdd = '${entry.value}$encoder';
      currentString += stringToAdd;
      counter += stringToAdd.length;
    } else {
      parts.add(currentString);
      counter = 0;
      currentString = '';
    }
  }

  final futures = <Future<String?>>[];

  for (final part in parts) {
    futures.add(client.translateString(
      stringToTranslate: part,
      sourceLanguage: message.sourceIntlCode,
      targetLanguage: message.targetIntlCode,
    ));
  }

  final results = await Future.wait(futures);

  final allParts = <String>[];

  print(results.length);

  for (final result in results) {
    if (result == null) continue;

    // final splittedWords = <String>[];
    // var currentWord = '';
    // var isMatchingSeparator = false;
    // var separatorIndex = 0;
    // for (var i = 0; i < result.length; i++) {
    //   final currentChar = result[i];
    //
    //   if (isMatchingSeparator && currentChar == ' ') {
    //     continue;
    //   }
    //
    //   if (separatorIndex == separator.length - 1) {
    //     splittedWords.add(currentWord);
    //     currentWord = '';
    //     separatorIndex = 0;
    //     isMatchingSeparator = false;
    //   } else if (currentChar == separator[separatorIndex]) {
    //     isMatchingSeparator = true;
    //     separatorIndex++;
    //   } else {
    //     currentWord += currentChar;
    //   }
    // }
    final re = RegExp(r'©™©|© ™©|©™ ©|© ™ ©|©  ™©|©™  ©{0,}');
    print(result.split(re));
    allParts.addAll(result.split(re));
    // allParts.addAll(splittedWords);
  }

  print(allParts.length);
  print(masterTranslationEntriesAsList.length);

  String? nextWordToInsert = allParts.first;
  int currentStringIndex = 0;

  for (var i = 0; i < masterTranslationEntriesAsList.length; i++) {
    final key = masterTranslationEntriesAsList[i].key;
    if (!resultMap.containsKey(key)) {
      resultMap[key] = nextWordToInsert;
      currentStringIndex++;
      nextWordToInsert = allParts[currentStringIndex];
    }
  }

  return resultMap;
}
