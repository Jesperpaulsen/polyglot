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

  Casing({
    required this.type,
    required this.title,
  });
}
