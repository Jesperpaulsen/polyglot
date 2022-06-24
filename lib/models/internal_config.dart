class InternalConfig {
  late String? projectConfigPath;

  InternalConfig({
    this.projectConfigPath,
  });

  InternalConfig.fromJson(Map<String, dynamic> json) {
    projectConfigPath = json['configPath'];
  }

  Map<String, dynamic> toJson() {
    return {
      'configPath': projectConfigPath,
    };
  }
}
