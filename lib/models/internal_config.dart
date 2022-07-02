class InternalConfig {
  String? projectConfigPath;
  List<String> projects;

  InternalConfig({
    this.projectConfigPath,
    this.projects = const [],
  });

  InternalConfig.fromJson(Map<String, dynamic> json)
      : projectConfigPath = json['configPath'] ?? '',
        projects =
            json['projects'] != null ? List<String>.from(json['projects']) : [];

  Map<String, dynamic> toJson() {
    return {
      'configPath': projectConfigPath,
      'projects': projects,
    };
  }
}
