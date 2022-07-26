import 'package:recase/recase.dart';

enum CASING_TYPES {
  SNAKE_CASE,
  PARAM_CASE,
  PASCAL_CASE,
  HEADER_CASE,
  CAMEL_CASE,
  CONSTANT_CASE,
}

class Casing {
  CASING_TYPES type;
  String title;
  String Function(String input) converter;

  Casing({required this.type, required this.converter})
      : title = converter(type.name);
}

Map<CASING_TYPES, Casing> casingsMap = {
  CASING_TYPES.SNAKE_CASE: Casing(
    type: CASING_TYPES.SNAKE_CASE,
    converter: (input) => input.sentenceCase,
  ),
  CASING_TYPES.PARAM_CASE: Casing(
    type: CASING_TYPES.PARAM_CASE,
    converter: (input) => input.sentenceCase,
  ),
  CASING_TYPES.PASCAL_CASE: Casing(
    type: CASING_TYPES.PASCAL_CASE,
    converter: (input) => input.sentenceCase,
  ),
  CASING_TYPES.HEADER_CASE: Casing(
    type: CASING_TYPES.HEADER_CASE,
    converter: (input) => input.sentenceCase,
  ),
  CASING_TYPES.CAMEL_CASE: Casing(
    type: CASING_TYPES.CAMEL_CASE,
    converter: (input) => input.sentenceCase,
  ),
  CASING_TYPES.CONSTANT_CASE: Casing(
    type: CASING_TYPES.CONSTANT_CASE,
    converter: (input) => input.sentenceCase,
  ),
};
