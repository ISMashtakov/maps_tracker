import 'package:flutter/material.dart';

import '../models/adventure.dart';
import '../services/adventure_repository.dart';
import 'tracker_map_view.dart';

const String _duplicateFileMessage = 'Файл уже загружен';
const String _invalidFileMessage = 'Некорректный файл приключения';
const String _noAdventuresMessage = 'Нет загруженных приключений';
const String _loadLevelButtonText = 'Загрузка уровня';
const String _mainMenuTitle = 'Главное меню';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final AdventureRepository _repository = AdventureRepository();
  List<Adventure> _adventures = [];

  @override
  void initState() {
    super.initState();
    _loadAdventures();
  }

  Future<void> _loadAdventures() async {
    final adventures = await _repository.loadAdventures();
    setState(() {
      _adventures = adventures;
    });
  }

  Future<void> _loadLevel() async {
    final result = await _repository.pickAndLoadAdventure(_adventures);

    if (result.isDuplicate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(_duplicateFileMessage)),
        );
      }
      return;
    }

    if (result.isError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(_invalidFileMessage)),
        );
      }
      return;
    }

    if (result.adventure != null) {
      setState(() {
        _adventures.add(result.adventure!);
      });
      await _repository.saveAdventures(_adventures);
    }
  }

  Future<void> _removeAdventure(int index) async {
    setState(() {
      _adventures.removeAt(index);
    });
    await _repository.saveAdventures(_adventures);
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
                                              adventure: _adventures[index],
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