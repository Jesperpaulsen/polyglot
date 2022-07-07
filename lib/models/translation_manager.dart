import 'package:polyglot/services/language_code_to_readable_name.dart';

class TranslationManager extends Comparable<TranslationManager> {
  final Map<String, String?> translations;
  final String intlCode;
  late final String? intlLanguageName;
  final bool isMaster;

  TranslationManager({
    required this.intlCode,
    this.translations = const <String, String?>{},
    required this.isMaster,
  }) {
    intlLanguageName =
        LanguageCodeToReadableName.instance.getLanguageNameForCode(intlCode);
  }

  @override
  int compareTo(TranslationManager other) {
    if (isMaster == true) {
      return -1;
    }
    return 1;
  }
}
