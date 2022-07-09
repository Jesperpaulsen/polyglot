import 'package:polyglot/models/internal_project_config.dart';

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

    print(json);

    try {
      projects = json['projects'] != null
          ? (json['projects'] as List<dynamic>)
              .map((project) => InternalProjectConfig.fromJson(project))
              .toList()
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
