import 'dart:io';
import 'package:yaml/yaml.dart';

class StageParams {
  final String? message;

  StageParams({this.message});

  static StageParams? fromYaml(dynamic yaml, String type) {
    if (yaml is! YamlMap) return null;

    if (type == 'text') {
      final msg = yaml['message'];
      if (msg is String) {
        return StageParams(message: msg);
      }
    }

    return StageParams();
  }
}

class Stage {
  final String name;
  final String type;
  final double distance;
  final StageParams params;
  final double targetLat;
  final double targetLng;

  Stage({
    required this.name,
    required this.type,
    required this.distance,
    required this.params,
    required this.targetLat,
    required this.targetLng,
  });

  static Stage? fromYaml(dynamic yaml) {
    if (yaml is! YamlMap) return null;

    final name = yaml['name'];
    final type = yaml['type'];
    if (name is! String || name.trim().isEmpty) return null;
    if (type is! String || (type != 'text' && type != 'image')) return null;

    final distance = yaml['distance'];
    final double distanceValue = distance is num ? distance.toDouble() : 10.0;

    final paramsYaml = yaml['params'];
    final params = StageParams.fromYaml(paramsYaml, type) ?? StageParams();

    final target = yaml['target'];
    if (target is! String) return null;
    
    final targetParts = target.split(',');
    if (targetParts.length != 2) return null;

    final lat = double.tryParse(targetParts[0].trim());
    final lng = double.tryParse(targetParts[1].trim());
    if (lat == null || lng == null) return null;

    return Stage(
      name: name.trim(),
      type: type,
      distance: distanceValue,
      params: params,
      targetLat: lat,
      targetLng: lng,
    );
  }
}

class Adventure {
  final String filePath;
  final String version;
  final String name;
  final List<Stage> stages;

  Adventure({
    required this.filePath,
    required this.version,
    required this.name,
    required this.stages,
  });

  static Adventure? fromFile(File file) {
    try {
      final content = file.readAsStringSync();
      final yamlDoc = loadYaml(content);

      if (yamlDoc is! YamlMap) {
        return null;
      }

      final version = yamlDoc['version'];
      if (version is! String || version.trim().isEmpty) {
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

      final stagesYaml = quest['stages'];
      final stages = <Stage>[];
      
      if (stagesYaml is YamlList) {
        for (final stageYaml in stagesYaml) {
          final stage = Stage.fromYaml(stageYaml);
          if (stage != null) {
            stages.add(stage);
          }
        }
      } else if (stagesYaml is YamlMap) {
        final stage = Stage.fromYaml(stagesYaml);
        if (stage != null) {
          stages.add(stage);
        }
      }

      return Adventure(
        filePath: file.path,
        version: version.trim(),
        name: name.trim(),
        stages: stages,
      );
    } catch (e) {
      return null;
    }
  }
}