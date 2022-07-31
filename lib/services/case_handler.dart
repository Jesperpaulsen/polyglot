import 'package:polyglot/models/casing.dart';

class CaseHandler {
  final RegExp _upperAlphaRegex = RegExp(r'[A-Z]');
  final _symbolSet = {' ', '.', '/', '_', '\\', '-'};

  late final String _originalText;
  late final List<String> _words;

  static final casingTitles = {
    CASING_TYPES.SNAKE_CASE: Casing(
      type: CASING_TYPES.SNAKE_CASE,
      title: 'snake_case',
    ),
    CASING_TYPES.PARAM_CASE: Casing(
      type: CASING_TYPES.PARAM_CASE,
      title: 'param-case',
    ),
    CASING_TYPES.PASCAL_CASE: Casing(
      type: CASING_TYPES.PASCAL_CASE,
      title: 'PascalCase',
    ),
    CASING_TYPES.HEADER_CASE: Casing(
      type: CASING_TYPES.HEADER_CASE,
      title: 'Header-Case',
    ),
    CASING_TYPES.CAMEL_CASE: Casing(
      type: CASING_TYPES.CAMEL_CASE,
      title: 'camelCase',
    ),
    CASING_TYPES.CONSTANT_CASE: Casing(
      type: CASING_TYPES.CONSTANT_CASE,
      title: 'CONSTANT_CASE',
    )
  };

  CaseHandler(String text) {
    _originalText = text;
    _words = _groupIntoWords(_originalText);
  }

  String getCasedString() {
    return _getSentenceCase();
  }

  List<String> _groupIntoWords(String text) {
    StringBuffer sb = StringBuffer();
    List<String> words = [];
    bool isAllCaps = text.toUpperCase() == text;

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      String? nextChar = i + 1 == text.length ? null : text[i + 1];

      if (_symbolSet.contains(char)) {
        continue;
      }

      sb.write(char);

      bool isEndOfWord = nextChar == null ||
          (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
          _symbolSet.contains(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }

  String _getSentenceCase({String separator = ' '}) {
    List<String> words = _words.map((word) => word.toLowerCase()).toList();
    if (_words.isNotEmpty) {
      words[0] = _upperCaseFirstLetter(words[0]);
    }

    return words.join(separator);
  }

  String _upperCaseFirstLetter(String word) {
    return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
  }
}
