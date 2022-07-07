import 'package:polyglot/services/language_code_to_readable_name.dart';

class LanguageConfig {
  String pathToi18nFile;
  String languageCode;
  String? displayLanguage;
  bool isMaster;

  LanguageConfig({
    required this.pathToi18nFile,
    required this.languageCode,
    required this.isMaster,
  });

  LanguageConfig.fromJson(Map<String, dynamic> json)
      : pathToi18nFile = json['pathToi18nFile'] ?? '',
        languageCode = json['languageCode'] ?? '',
        isMaster = json['isMaster'] ?? false,
        displayLanguage =
            LanguageCodeToReadableName.instance.getLanguageNameForCode(
          json['languageCode'] ?? '',
        );

  toJson() {
    return {
      'pathToi18nFile': pathToi18nFile,
      'languageCode': languageCode,
      'isMaster': isMaster
    };
  }
}
