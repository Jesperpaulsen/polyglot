import 'package:intl_ui/models/internal_project_config.dart';

class InternalConfig {
  InternalProjectConfig? internalProjectConfig;
  var projects = <InternalProjectConfig>[];

  InternalConfig({
    InternalProjectConfig? internalProjectConfig,
    this.projects = const <InternalProjectConfig>[],
  }) : internalProjectConfig =
            internalProjectConfig ?? InternalProjectConfig(path: '');

  InternalConfig.fromJson(Map<String, dynamic> json) {
    try {
      internalProjectConfig = json['internalProjectConfig'] != null
          ? InternalProjectConfig.fromJson(json['internalProjectConfig'])
          : null;
    } catch (e) {
      internalProjectConfig = InternalProjectConfig(path: '');
    }

    try {
      projects = json['projects'] != null
          ? json['projects']
              .map((project) => InternalProjectConfig.fromJson(project))
          : <InternalProjectConfig>[];
    } catch (e) {
      projects = [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'internalProjectConfig': internalProjectConfig,
      'projects': projects.map((project) => project.toJson()).toList(),
    };
  }
}
