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
    required Map<String, String> masterTranslations,
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
  final Map<String, String> masterTranslations;
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

  const separator = '*_:;"#&%%/)(=%#""#)';

  final parts = <String>[];
  var counter = 0;
  var currentString = '';
  final resultMap = message.existingTranslations != null
      ? Map.from(message.existingTranslations!)
      : <String, String?>{};

  final masterTranslationEntriesAsList =
      message.masterTranslations.entries.toList();

  for (final entry in masterTranslationEntriesAsList) {
    if (resultMap.containsKey(entry.key)) {
      continue;
    }

    if (counter < 20000) {
      currentString += '$separator$entry.word';
      counter += currentString.length;
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

  for (final result in results) {
    if (result == null) continue;
    allParts.addAll(result.split(separator));
  }

  for (var i = 0; i < masterTranslationEntriesAsList.length; i++) {
    final key = masterTranslationEntriesAsList[i].key;

    resultMap[key] = allParts[i];
  }

  message.port.send(resultMap);
}
