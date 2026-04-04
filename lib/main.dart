import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu_screen.dart';

void main() {
  runApp(const MapsTrackerApp());
}

class MapsTrackerApp extends StatelessWidget {
  const MapsTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    return MaterialApp(
      title: 'Maps Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
