import 'dart:io';
import 'package:yaml/yaml.dart';

class Adventure {
  final String filePath;
  final String name;

  Adventure({
    required this.filePath,
    required this.name,
  });

  static Adventure? fromFile(File file) {
    try {
      final content = file.readAsStringSync();
      final yamlDoc = loadYaml(content);

      if (yamlDoc is! YamlMap) {
        return null;
      }

      final quest = yamlDoc['quest'];
      if (quest is! YamlMap) {
        return null;
      }

      final name = quest['name'];
      if (name is! String || name.trim().isEmpty) {
        return null;
      }

      return Adventure(
        filePath: file.path,
        name: name.trim(),
      );
    } catch (e) {
      return null;
    }
  }
}