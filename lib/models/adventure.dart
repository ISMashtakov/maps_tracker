import 'dart:io';
import 'package:xml/xml.dart';

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
      final document = XmlDocument.parse(content);
      final questElement = document.getElement('quest');

      if (questElement == null) {
        return null;
      }

      final nameElement = questElement.getElement('name');
      if (nameElement == null || nameElement.innerText.trim().isEmpty) {
        return null;
      }

      return Adventure(
        filePath: file.path,
        name: nameElement.innerText.trim(),
      );
    } catch (e) {
      return null;
    }
  }
}