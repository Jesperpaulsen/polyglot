import 'dart:io';

import 'package:flutter/services.dart';

LogicalKeyboardKey getMetaKey() {
  if (Platform.isMacOS) {
    return LogicalKeyboardKey.meta;
  }
  return LogicalKeyboardKey.control;
}
