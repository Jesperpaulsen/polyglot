import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:polyglot/services/config_handler.dart';
import 'package:polyglot/services/translation_handler/translate_batch_text_on_isolate.dart';

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

    Isolate.spawn<BatchTextIsolateMessage>(
      translateBatchTextOnIsolate,
      BatchTextIsolateMessage(
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
