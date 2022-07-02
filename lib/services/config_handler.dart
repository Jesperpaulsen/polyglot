import 'dart:async';
import 'dart:io';

import 'package:intl_ui/models/internal_config.dart';
import 'package:intl_ui/models/project_config.dart';
import 'package:intl_ui/services/file_handler.dart';

class ConfigHandler {
  final _isInitialized = Completer();
  InternalConfig? _internalConfig;
  ProjectConfig? _projectConfig;
  String? translationDirectory;

  ConfigHandler._privateConstructor() {
    _initialize();
  }

  static final instance = ConfigHandler._privateConstructor();

  Future<void> ensureInitialised() async {
    return _isInitialized.future;
  }

  Future<void> _initialize() async {
    _internalConfig = await _initializeInternalConfig();
    _projectConfig = await _initializeProjectConfig(_internalConfig!);
    _isInitialized.complete();
  }

  Future<InternalConfig> _initializeInternalConfig() async {
    var internalConfig = await _readInternalConfig();
    if (internalConfig == null) {
      internalConfig = InternalConfig();
      _storeInternalConfig(internalConfig);
    }
    translationDirectory = _getProjectConfigDirectory(internalConfig);
    return internalConfig;
  }

  Future<void> refreshConfig() async {
    if (_internalConfig == null) return;
    _projectConfig = await _initializeProjectConfig(_internalConfig!);
  }

  String _getProjectConfigDirectory(InternalConfig internalConfig) {
    return Directory.fromUri(Uri(path: internalConfig.projectConfigPath))
        .parent
        .path;
  }

  Future<ProjectConfig> _initializeProjectConfig(
    InternalConfig internalConfig,
  ) async {
    var projectConfig = await _readProjectConfig(
      internalConfig.projectConfigPath ?? '',
    );
    if (projectConfig == null) {
      projectConfig = ProjectConfig();
      _storeProjectConfig(projectConfig);
    }
    print(projectConfig.languageConfigs.entries
        .map((e) => print(e.value.pathToi18nFile)));
    return projectConfig;
  }

  InternalConfig? get internalConfig {
    return _internalConfig;
  }

  ProjectConfig? get projectConfig {
    return _projectConfig;
  }

  Future<void> changePathToProjectConfigFile(String newPath) async {
    if (internalConfig == null) {
      throw Exception('Config is null');
    }
    internalConfig!.projectConfigPath = newPath;
    translationDirectory = _getProjectConfigDirectory(internalConfig!);
    _projectConfig = await _initializeProjectConfig(internalConfig!);
    await saveInternalConfig();
  }

  Future<InternalConfig?> _readInternalConfig() async {
    try {
      final json =
          await FileHandler.instance.readJsonFile(fileName: 'config.json');
      return InternalConfig.fromJson(json);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> saveInternalConfig() {
    if (internalConfig == null) {
      return Future.value();
    }
    if (internalConfig!.projectConfigPath != null &&
        !internalConfig!.projects.contains(internalConfig!.projectConfigPath)) {
      internalConfig!.projects.add(internalConfig!.projectConfigPath!);
    }
    return _storeInternalConfig(internalConfig!);
  }

  Future<void> removeProjectFromInternalConfig(String project) async {
    if (internalConfig?.projectConfigPath == null) {
      return;
    }
    if (project == internalConfig!.projectConfigPath) {
      return;
    }
    internalConfig!.projects.remove(project);
    saveInternalConfig();
  }

  Future<void> saveProjectConfig() {
    if (projectConfig == null) {
      return Future.value();
    }
    return _storeProjectConfig(projectConfig!);
  }

  Future<void> _storeInternalConfig(InternalConfig config) async {
    await FileHandler.instance.writeJsonFile(
      fileName: 'config.json',
      content: config.toJson(),
    );
  }

  Future<ProjectConfig?> _readProjectConfig(String path) async {
    try {
      final json = await FileHandler.instance.readJsonFile(fullPath: path);
      return ProjectConfig.fromJson(json);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> _storeProjectConfig(ProjectConfig config) async {
    if (internalConfig?.projectConfigPath == null) {
      throw Exception('Project config is null');
    }
    try {
      await FileHandler.instance.writeJsonFile(
          fullPath: internalConfig!.projectConfigPath,
          content: config.toJson());
    } catch (e) {
      print(e);
    }
  }
}
