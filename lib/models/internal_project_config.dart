import 'package:intl_ui/utils/get_random_id.dart';

class InternalProjectConfig {
  String id;
  String path;
  String? translateApiKey;

  InternalProjectConfig({
    String? id,
    required this.path,
    this.translateApiKey,
  }) : id = id ?? getRandomId(5);

  InternalProjectConfig.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? getRandomId(5),
        path = json['path'] ?? '',
        translateApiKey = json['translateApiKey'] ?? '';

  toJson() {
    return {
      'id': id,
      'path': path,
      'translateApiKey': translateApiKey,
    };
  }
}
