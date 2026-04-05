import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/adventure.dart';
import 'tracker_map_view.dart';

const String _duplicateFileMessage = 'Файл уже загружен';
const String _invalidFileMessage = 'Некорректный файл приключения';
const String _errorLoadMessage = 'Ошибка загрузки файла: ';
const String _noAdventuresMessage = 'Нет загруженных приключений';
const String _loadLevelButtonText = 'Загрузка уровня';
const String _mainMenuTitle = 'Главное меню';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<Adventure> _adventures = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPaths();
  }

  Future<void> _loadSavedPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList('adventure_paths') ?? [];

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
      await prefs.setStringList('adventure_paths', validPaths);
    }

    setState(() {
      _adventures = validAdventures;
    });
  }

  Future<void> _savePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = _adventures.map((a) => a.filePath).toList();
    await prefs.setStringList('adventure_paths', paths);
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

        final newAdventure = Adventure.fromFile(newFile);
        if (newAdventure == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(_invalidFileMessage)),
            );
          }
          return;
        }

        final isDuplicate = _adventures.any((adventure) {
          return adventure.name == newAdventure.name;
        });

        if (isDuplicate) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(_duplicateFileMessage)),
            );
          }
          return;
        }

        setState(() {
          _adventures.add(newAdventure);
        });
        await _savePaths();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_errorLoadMessage$e')),
        );
      }
    }
  }

  Future<void> _removeAdventure(int index) async {
    setState(() {
      _adventures.removeAt(index);
    });
    await _savePaths();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_mainMenuTitle),
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
                child: const Text(_loadLevelButtonText),
              ),
            ),
          ),
          Expanded(
            child: _adventures.isEmpty
                ? const Center(
                    child: Text(_noAdventuresMessage),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: List.generate(_adventures.length, (index) {
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
                                              adventureFile: File(_adventures[index].filePath),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(_adventures[index].name),
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