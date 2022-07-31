import 'package:polyglot/models/language_config.dart';

class ProjectConfig {
  late Map<String, LanguageConfig> languageConfigs;
  late String? translationKeyInFiles;

  ProjectConfig({
    Map<String, LanguageConfig>? languageConfigs,
    this.translationKeyInFiles,
  }) : languageConfigs = languageConfigs ?? <String, LanguageConfig>{};

  ProjectConfig.fromJson(Map<String, dynamic> json) {
    final res = <String, LanguageConfig>{};
    for (final languageConfig in json['languageConfigs'].values) {
      final parsedConfig = LanguageConfig.fromJson(languageConfig);
      res[parsedConfig.languageCode] = parsedConfig;
    }
    languageConfigs = res;
    translationKeyInFiles = json['translationKeyInFiles'];
  }

  Map<String, dynamic> toJson() {
    final convertedLanguageConfigs = <String, dynamic>{};

    for (final languageConfig in languageConfigs.values) {
      convertedLanguageConfigs[languageConfig.languageCode] =
          languageConfig.toJson();
    }

    return {
      'languageConfigs': convertedLanguageConfigs,
      'translationKeyInFiles': translationKeyInFiles,
    };
  }
}
