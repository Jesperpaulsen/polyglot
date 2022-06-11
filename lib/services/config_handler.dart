import 'dart:async';

import 'package:intl_ui/models/config.dart';

class ConfigHandler {
  final _isInitialized = Completer();
  Config? _config;

  ConfigHandler._privateConstructor();

  static final instance = ConfigHandler._privateConstructor();

  Future<void> ensureInitialised() async {
    return _isInitialized.future;
  }

  Future<void> initialize() async {
    final config = await _readConfig();
    _config = config;
    _isInitialized.complete();
  }

  Future<Config?> _readConfig() async {}

  Future<void> _storeConfig(Config config) async {}
}
