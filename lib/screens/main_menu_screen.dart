import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tracker_map_view.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<String> _adventurePaths = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPaths();
  }

  Future<void> _loadSavedPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList('adventure_paths') ?? [];

    final validPaths = <String>[];
    for (final path in paths) {
      if (await File(path).exists()) {
        validPaths.add(path);
      }
    }

    if (validPaths.length != paths.length) {
      await prefs.setStringList('adventure_paths', validPaths);
    }

    setState(() {
      _adventurePaths = validPaths;
    });
  }

  Future<void> _savePaths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('adventure_paths', _adventurePaths);
  }

  Future<void> _loadLevel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final newPath = result.files.single.path!;
        final newFile = File(newPath);
        final newFileName = newFile.path.split(Platform.pathSeparator).last;

        final isDuplicate = _adventurePaths.any((path) {
          final existingFile = File(path);
          final existingFileName = existingFile.path.split(Platform.pathSeparator).last;
          return existingFileName == newFileName;
        });

        if (isDuplicate) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Файл уже загружен')),
            );
          }
          return;
        }

        setState(() {
          _adventurePaths.add(newPath);
        });
        await _savePaths();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки файла: $e')),
        );
      }
    }
  }

  Future<void> _removeAdventure(int index) async {
    setState(() {
      _adventurePaths.removeAt(index);
    });
    await _savePaths();
  }

  String _getFileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главное меню'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadLevel,
                child: const Text('Загрузка уровня'),
              ),
            ),
          ),
          Expanded(
            child: _adventurePaths.isEmpty
                ? const Center(
                    child: Text('Нет загруженных приключений'),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: List.generate(_adventurePaths.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TrackerMapView(
                                              adventureFile: File(_adventurePaths[index]),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(_getFileName(_adventurePaths[index])),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeAdventure(index),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
