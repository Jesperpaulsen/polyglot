enum CASING_TYPES {
  UPPER_SNAKE,
  SNAKE_CASE,
  LOWER_CASE,
  UPPER_CASE,
  PASCAL_CASE,
  CAMEL_CASE,
  TITLE_CASE,
  MIXED_CASE,
  UNKNOWN
}

class Casing {
  CASING_TYPES type;
  RegExp exp;

  Casing({required this.type, required String pattern}) :
      exp = RegExp(pattern);

  bool validatorFn(String testString) {
    return exp.(testString)
  }
}

Map<CASING_TYPES, Casing> casingsMap = {
  CASING_TYPES.UPPER_SNAKE: Casing(type: CASING_TYPES.UPPER_SNAKE, pattern: '([A-Z][A-Z0-9_]+)+'),
  CASING_TYPES.SNAKE_CASE: Casing(type: )
}
