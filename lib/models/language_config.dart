import 'package:intl_ui/services/language_code_to_readable_name.dart';

class LanguageConfig {
  String pathToConfigFile;
  String languageCode;
  String? displayLanguage;

  LanguageConfig({
    required this.pathToConfigFile,
    required this.languageCode,
  });

  LanguageConfig.fromJson(Map<String, dynamic> json)
      : pathToConfigFile = json['pathToConfigFile'] ?? '',
        languageCode = json['languageCode'] ?? '',
        displayLanguage = LanguageCodeToReadableName.instance
            .getLanguageNameForCode(json['languageCode'] ?? '');

  toJson() {
    return {
      'pathToConfigFile': pathToConfigFile,
      'languageCode': languageCode,
    };
  }
}
