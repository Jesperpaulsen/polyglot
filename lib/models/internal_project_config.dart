import 'package:intl_ui/utils/get_random_id.dart';

class InternalProjectConfig {
  String id;
  String path;

  InternalProjectConfig({
    String? id,
    required this.path,
  }) : id = id ?? getRandomId(5);

  InternalProjectConfig.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? getRandomId(5),
        path = json['path'] ?? '';

  toJson() {
    return {
      'id': id,
      'path': path,
    };
  }
}
