import 'package:dio/dio.dart';
import 'package:intl_ui/services/config_handler.dart';

class TranslationClient {
  final String apiKey;
  final _dio = Dio();

  TranslationClient({required this.apiKey}) {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: _onRequestInterceptor));
  }

  _onRequestInterceptor(
      RequestOptions options, RequestInterceptorHandler handler) {
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
}
