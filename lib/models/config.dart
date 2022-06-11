import 'package:intl_ui/models/language_config.dart';

class Config {
  late final Map<String, LanguageConfig> languageConfigs;
  late final String? translateAPIKey;

  Config({
    this.languageConfigs = const <String, LanguageConfig>{},
    this.translateAPIKey,
  });

  Config.fromJson(Map<String, dynamic> json) {
    final res = <String, LanguageConfig>{};
    for (final languageConfig in json['languageConfigs']) {
      final parsedConfig = LanguageConfig.fromJson(languageConfig);
      res[parsedConfig.languageCode] = parsedConfig;
    }
    languageConfigs = res;
    translateAPIKey = json['translateAPIKey'];
  }

  Map<String, dynamic> toJson() {
    final convertedLanguageConfigs = <String, dynamic>{};

    for (final languageConfig in languageConfigs.values) {
      convertedLanguageConfigs[languageConfig.languageCode] =
          languageConfig.toJson();
    }

    return {
      'languageConfigs': convertedLanguageConfigs,
      'translateAPIKey': translateAPIKey
    };
  }
}
