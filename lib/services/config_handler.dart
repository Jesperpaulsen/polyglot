import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:polyglot/models/internal_config.dart';
import 'package:polyglot/models/internal_project_config.dart';
import 'package:polyglot/models/language_config.dart';
import 'package:polyglot/models/project_config.dart';
import 'package:polyglot/services/file_handler.dart';
import 'package:polyglot/services/translation_handler/translation_handler.dart';

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
    if (!_isInitialized.isCompleted) _isInitialized.complete();
  }

  Future<InternalConfig> _initializeInternalConfig() async {
    var internalConfig = await _readInternalConfig();
    if (internalConfig == null) {
      internalConfig = InternalConfig();
      _storeInternalConfig(internalConfig);
    }

    internalConfig.internalProjectConfig ??= InternalProjectConfig(path: '');
    _makeSureInternalConfigHasLatestVersionOfOwnProject(internalConfig);
    translationDirectory = _getProjectConfigDirectory(internalConfig);
    return internalConfig;
  }

  void _makeSureInternalConfigHasLatestVersionOfOwnProject(
      InternalConfig internalConfig) {
    final indexOfInternalConfig = internalConfig.projects.indexWhere(
        (project) => project.id == internalConfig.internalProjectConfig!.id);

    if (indexOfInternalConfig == -1) {
      internalConfig.projects.add(internalConfig.internalProjectConfig!);
    } else {
      internalConfig.projects[indexOfInternalConfig] =
          internalConfig.internalProjectConfig!;
    }
  }

  Future<void> refreshConfig() async {
    if (_internalConfig == null) return;
    _projectConfig = await _initializeProjectConfig(_internalConfig!);
  }

  String _getProjectConfigDirectory(InternalConfig internalConfig) {
    return p.dirname(internalConfig.internalProjectConfig?.path ?? '');
  }

  Future<ProjectConfig> _initializeProjectConfig(
    InternalConfig internalConfig,
  ) async {
    var projectConfig = await _readProjectConfig(
      internalConfig.internalProjectConfig?.path ?? '',
    );

    if (projectConfig == null) {
      projectConfig = ProjectConfig();
      _storeProjectConfig(projectConfig);
    }

    return projectConfig;
  }

  InternalConfig? get internalConfig {
    return _internalConfig;
  }

  ProjectConfig? get projectConfig {
    return _projectConfig;
  }

  Future<void> changeProject(String newPath) async {
    if (internalConfig?.internalProjectConfig == null) {
      throw Exception('Config is null');
    }

    final selectedProject = internalConfig!.projects.firstWhere(
        (element) => element.path == newPath,
        orElse: () => InternalProjectConfig(path: newPath));

    internalConfig!.internalProjectConfig = selectedProject;
    translationDirectory = _getProjectConfigDirectory(internalConfig!);
    _projectConfig = await _initializeProjectConfig(internalConfig!);

    TranslationHandler.instance.initialize();

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

  Future<void> saveInternalConfig() async {
    if (internalConfig?.internalProjectConfig == null) {
      throw Exception(
          'InternalProjectConfig was null when saving internalConfig');
    }

    _makeSureInternalConfigHasLatestVersionOfOwnProject(internalConfig!);

    await _storeInternalConfig(internalConfig!);
    await _initialize();
  }

  Future<void> removeProjectFromInternalConfig(String projectId) async {
    if (internalConfig?.internalProjectConfig?.path == null) {
      return;
    }
    if (projectId == internalConfig!.internalProjectConfig?.id) {
      return;
    }
    internalConfig!.projects.removeWhere((project) => project.id == projectId);
    saveInternalConfig();
  }

  Future<void> saveProjectConfig() async {
    if (projectConfig == null) {
      return;
    }
    return _storeProjectConfig(projectConfig!);
  }

  Future<void> addLanguageToProject(String intlCode, String fileName) async {
    if (projectConfig == null) {
      return;
    }

    projectConfig!.languageConfigs[intlCode] = LanguageConfig(
      pathToi18nFile: fileName,
      languageCode: intlCode,
      isMaster: projectConfig?.languageConfigs.isEmpty ?? true,
    );

    final content = <String, dynamic>{};

    if (projectConfig!.translationKeyInFiles != null &&
        projectConfig!.translationKeyInFiles!.isNotEmpty) {
      content[projectConfig!.translationKeyInFiles!] = {};
    }

    await FileHandler.instance.writeJsonFile(
      content: content,
      fileName: fileName,
      directory: translationDirectory,
    );
    return _storeProjectConfig(projectConfig!);
  }

  Future<void> _storeInternalConfig(InternalConfig config) async {
    await FileHandler.instance.writeJsonFile(
        fileName: 'config.json', content: config.toJson(), overwrite: true);
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
    if (internalConfig?.internalProjectConfig?.path == null) {
      throw Exception('Project config is null');
    }
    try {
      await FileHandler.instance.writeJsonFile(
        fullPath: internalConfig!.internalProjectConfig?.path,
        content: config.toJson(),
        overwrite: true,
      );
    } catch (e) {
      print(e);
    }
  }
}
