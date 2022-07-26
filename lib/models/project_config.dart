import 'package:polyglot/models/casing.dart';
import 'package:polyglot/models/language_config.dart';

class ProjectConfig {
  late Map<String, LanguageConfig> languageConfigs;
  late String? translationKeyInFiles;
  late Casing casing;

  ProjectConfig({
    Map<String, LanguageConfig>? languageConfigs,
    this.translationKeyInFiles,
    CASING_TYPES? casingType,
  })  : languageConfigs = languageConfigs ?? <String, LanguageConfig>{},
        casing = casingsMap[casingType ?? CASING_TYPES.SNAKE_CASE]!;

  ProjectConfig.fromJson(Map<String, dynamic> json) {
    final res = <String, LanguageConfig>{};
    for (final languageConfig in json['languageConfigs'].values) {
      final parsedConfig = LanguageConfig.fromJson(languageConfig);
      res[parsedConfig.languageCode] = parsedConfig;
    }
    languageConfigs = res;
    translationKeyInFiles = json['translationKeyInFiles'];
    casing = _getCasingOrDefaultFromString(json['casingType']);
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
      'casingType': casing.type.name
    };
  }

  Casing _getCasingOrDefaultFromString(String casing) {
    final casingKey =
        CASING_TYPES.values.asNameMap()[casing] ?? CASING_TYPES.SNAKE_CASE;
    return casingsMap[casingKey]!;
  }
}
