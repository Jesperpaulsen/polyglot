import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class LanguageCodeToReadableName {
  final _isInitialized = Completer();
  var _languageCodeToCountryName = <String, dynamic>{};

  LanguageCodeToReadableName._privateConstructor() {
    _initialize();
  }

  static final instance = LanguageCodeToReadableName._privateConstructor();

  Future<void> ensureInitialised() async {
    return _isInitialized.future;
  }

  Future<void> _initialize() async {
    final json =
        await rootBundle.loadString('assets/internalization_languages.json');
    _languageCodeToCountryName = jsonDecode(json);
    _isInitialized.complete();
  }

  String? getLanguageNameForCode(String languageCode) {
    return _languageCodeToCountryName[languageCode];
  }
}
