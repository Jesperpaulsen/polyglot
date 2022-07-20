import 'package:polyglot/models/internal_project_config.dart';

class InternalConfig {
  InternalProjectConfig? internalProjectConfig;
  var projects = <InternalProjectConfig>[];

  InternalConfig({
    InternalProjectConfig? internalProjectConfig,
    List<InternalProjectConfig>? projects,
  })  : internalProjectConfig =
            internalProjectConfig ?? InternalProjectConfig(path: ''),
        projects = projects ?? <InternalProjectConfig>[];

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
      projects = <InternalProjectConfig>[];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'internalProjectConfig': internalProjectConfig,
      'projects': projects.map((project) => project.toJson()).toList(),
    };
  }
}
