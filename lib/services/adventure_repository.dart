import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/adventure.dart';

class AdventureLoadResult {
  final Adventure? adventure;
  final bool isDuplicate;
  final bool isError;

  AdventureLoadResult({
    this.adventure,
    this.isDuplicate = false,
    this.isError = false,
  });
}

class AdventureRepository {
  static const String _prefsKey = 'adventure_paths';

  Future<List<Adventure>> loadAdventures() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_prefsKey) ?? [];

    final validAdventures = <Adventure>[];
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        final adventure = Adventure.fromFile(file);
        if (adventure != null) {
          validAdventures.add(adventure);
        }
      }
    }

    final validPaths = validAdventures.map((a) => a.filePath).toList();
    if (validPaths.length != paths.length) {
      await prefs.setStringList(_prefsKey, validPaths);
    }

    return validAdventures;
  }

  Future<void> saveAdventures(List<Adventure> adventures) async {
    final prefs = await SharedPreferences.getInstance();
    final paths = adventures.map((a) => a.filePath).toList();
    await prefs.setStringList(_prefsKey, paths);
  }

  Future<AdventureLoadResult> pickAndLoadAdventure(List<Adventure> currentAdventures) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return AdventureLoadResult();
      }

      final newPath = result.files.single.path!;
      final file = File(newPath);

      if (!await file.exists()) {
        return AdventureLoadResult(isError: true);
      }

      final adventure = Adventure.fromFile(file);
      if (adventure == null) {
        return AdventureLoadResult(isError: true);
      }

      final isDuplicate = currentAdventures.any((a) => a.name == adventure.name);
      if (isDuplicate) {
        return AdventureLoadResult(isDuplicate: true);
      }

      return AdventureLoadResult(adventure: adventure);
    } catch (e) {
      return AdventureLoadResult(isError: true);
    }
  }
}