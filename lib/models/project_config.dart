import 'package:polyglot/models/casing.dart';
import 'package:polyglot/models/language_config.dart';

class ProjectConfig {
  late Map<String, LanguageConfig> languageConfigs;
  late String? translationKeyInFiles;
  late CASING_TYPES casingType;

  ProjectConfig({
    Map<String, LanguageConfig>? languageConfigs,
    this.translationKeyInFiles,
    CASING_TYPES? casingType,
  })  : languageConfigs = languageConfigs ?? <String, LanguageConfig>{},
        casingType = casingType ?? CASING_TYPES.SNAKE_CASE;

  ProjectConfig.fromJson(Map<String, dynamic> json) {
    final res = <String, LanguageConfig>{};
    for (final languageConfig in json['languageConfigs'].values) {
      final parsedConfig = LanguageConfig.fromJson(languageConfig);
      res[parsedConfig.languageCode] = parsedConfig;
    }
    languageConfigs = res;
    translationKeyInFiles = json['translationKeyInFiles'];
    casingType = _getCasingTypeOrDefaultFromString(json['casingType']);
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
      'casingType': casingType.name
    };
  }

  CASING_TYPES _getCasingTypeOrDefaultFromString(String casing) {
    return CASING_TYPES.values.asNameMap()[casing] ?? CASING_TYPES.SNAKE_CASE;
  }
}
