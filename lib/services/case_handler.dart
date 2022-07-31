import 'package:polyglot/models/casing.dart';
import 'package:polyglot/services/config_handler.dart';

class CaseHandler {
  final RegExp _upperAlphaRegex = RegExp(r'[A-Z]');
  final _symbolSet = {' ', '.', '/', '_', '\\', '-'};

  late final CASING_TYPES _casingType;
  late final String _originalText;
  late final List<String> _words;
  late final Map<CASING_TYPES, String Function({String separator})> _casingsMap;

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

  CaseHandler(
    String text, {
    CASING_TYPES? casingType,
  }) {
    _originalText = text;
    _words = _groupIntoWords(_originalText);
    _casingType = casingType ??
        ConfigHandler.instance.projectConfig?.casingType ??
        CASING_TYPES.SNAKE_CASE;
    _casingsMap = {
      CASING_TYPES.SNAKE_CASE: _getSnakeCase,
      CASING_TYPES.PARAM_CASE: ({String separator = '_'}) =>
          _getSnakeCase(separator: separator),
      CASING_TYPES.PASCAL_CASE: _getPascalCase,
      CASING_TYPES.HEADER_CASE: ({String separator = '-'}) =>
          _getPascalCase(separator: separator),
      CASING_TYPES.CAMEL_CASE: _getCamelCase,
      CASING_TYPES.CONSTANT_CASE: _getConstantCase,
    };
  }

  String getCasedString() {
    return _casingsMap[_casingType]!();
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

  String _getCamelCase({String separator = ''}) {
    List<String> words = _words.map(_upperCaseFirstLetter).toList();
    if (_words.isNotEmpty) {
      words[0] = words[0].toLowerCase();
    }

    return words.join(separator);
  }

  String _getConstantCase({String separator = '_'}) {
    List<String> words = _words.map((word) => word.toUpperCase()).toList();

    return words.join(separator);
  }

  String _getPascalCase({String separator = ''}) {
    List<String> words = _words.map(_upperCaseFirstLetter).toList();

    return words.join(separator);
  }

  String _getSentenceCase({String separator = ' '}) {
    List<String> words = _words.map((word) => word.toLowerCase()).toList();
    if (_words.isNotEmpty) {
      words[0] = _upperCaseFirstLetter(words[0]);
    }

    return words.join(separator);
  }

  String _getSnakeCase({String separator = '_'}) {
    List<String> words = _words.map((word) => word.toLowerCase()).toList();

    return words.join(separator);
  }

  String _upperCaseFirstLetter(String word) {
    return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
  }
}
