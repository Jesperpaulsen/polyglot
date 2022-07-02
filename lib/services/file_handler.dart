import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileHandler {
  FileHandler._privateConstructor();

  static final instance = FileHandler._privateConstructor();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _combinePathAndFileNameToFile({
    String? directory,
    String? fileName,
  }) async {
    var internalPath = directory;
    internalPath ??= await _localPath;
    final fullPath = '$internalPath/$fileName';
    return File(fullPath);
  }

  Future<File> _getFile({
    String? directory,
    String? fileName,
    String? fullPath,
  }) async {
    if (fullPath != null) {
      return File(fullPath);
    }
    return await _combinePathAndFileNameToFile(
        directory: directory, fileName: fileName);
  }

  Future<Map<String, dynamic>> readJsonFile({
    String? directory,
    String? fileName,
    String? fullPath,
  }) async {
    final file = await _getFile(
      directory: directory,
      fileName: fileName,
      fullPath: fullPath,
    );
    final json = await file.readAsString();
    return jsonDecode(json);
  }

  Future<File> writeJsonFile({
    String? directory,
    String? fileName,
    String? fullPath,
    required Map<String, dynamic> content,
  }) async {
    final file = await _getFile(
      directory: directory,
      fileName: fileName,
      fullPath: fullPath,
    );
    return file.writeAsString(jsonEncode(content));
  }
}
