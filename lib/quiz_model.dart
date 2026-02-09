import 'dart:io';

class Quiz {
  final String name;
  final String? description;
  final String rawToml;
  final String? sourcePath; // original file path if imported

  Quiz({required this.name, this.description, required this.rawToml, this.sourcePath});

  // Very small TOML extractor for `name` and `description` fields.
  static Quiz fromTomlString(String toml, {String? sourcePath}) {
    final nameExp = RegExp(r'^\s*name\s*=\s*"([^"]+)"', multiLine: true);
    final descExp = RegExp(r'^\s*description\s*=\s*"([^"]+)"', multiLine: true);
    final nameMatch = nameExp.firstMatch(toml);
    final descMatch = descExp.firstMatch(toml);
    final name = nameMatch != null ? nameMatch.group(1)! : 'Unnamed Quiz';
    final desc = descMatch != null ? descMatch.group(1)! : null;
    return Quiz(name: name, description: desc, rawToml: toml, sourcePath: sourcePath);
  }

  // Save the raw TOML to a given path
  Future<void> saveToPath(String path) async {
    final file = File(path);
    await file.writeAsString(rawToml);
  }
}
