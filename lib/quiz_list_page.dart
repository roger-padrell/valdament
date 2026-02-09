import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valdament/quiz_page.dart';
import 'quiz_model.dart';
import 'quiz_editor_page.dart';
import 'settings_page.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final List<Quiz> _quizzes = [];
  bool _selectionMode = false;
  final Set<int> _selected = {};
  bool _copyOnImport = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _copyOnImport = sp.getBool('copy_to_app_dir') ?? false;
    });
  }

  Future<void> _importToml() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['toml'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    try {
      final content = await File(path).readAsString();
      if (_copyOnImport) {
        // copy to app documents directory so app owns its quizzes
        final dir = await getApplicationDocumentsDirectory();
        final filename = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        final out = File('${dir.path}/$filename');
        await out.writeAsString(content);
        final quiz = Quiz.fromTomlString(content, sourcePath: out.path);
        setState(() => _quizzes.add(quiz));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported: ${quiz.name} (copied to app dir)')));
      } else {
        final quiz = Quiz.fromTomlString(content, sourcePath: path);
        setState(() => _quizzes.add(quiz));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported: ${quiz.name}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  Future<void> _exportQuiz(Quiz quiz) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final out = File('${dir.path}/${quiz.name.replaceAll(' ', '_')}.toml');
      await out.writeAsString(quiz.rawToml);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to ${out.path}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _exportSelected() async {
    final sel = _selected.toList()..sort();
    if (sel.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      for (final idx in sel) {
        final quiz = _quizzes[idx];
        final out = File('${dir.path}/${quiz.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.toml');
        await out.writeAsString(quiz.rawToml);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported ${sel.length} quizzes to app documents')));
      setState(() {
        _selectionMode = false;
        _selected.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bulk export failed: $e')));
    }
  }

  Future<void> _removeSelected() async {
    if (_selected.isEmpty) return;
    final removeList = _selected.toList()..sort((a, b) => b.compareTo(a));
    for (final idx in removeList) {
      final quiz = _quizzes[idx];
      if (quiz.sourcePath != null) {
        try {
          final f = File(quiz.sourcePath!);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      _quizzes.removeAt(idx);
    }
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed selected quizzes')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectionMode
          ? AppBar(
              title: Text('${_selected.length} selected'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _selectionMode = false;
                  _selected.clear();
                }),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.download_outlined), onPressed: _exportSelected),
                IconButton(icon: const Icon(Icons.delete), onPressed: _removeSelected),
              ],
            )
          : AppBar(
              title: const Text('Quizzes'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.file_upload_outlined),
                  tooltip: 'Import TOML',
                  onPressed: _importToml,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
                ),
              ],
            ),
      body: ListView.builder(
        itemCount: _quizzes.length,
        itemBuilder: (context, index) {
          final quiz = _quizzes[index];
          final selected = _selected.contains(index);
          return ListTile(
            selected: selected,
            title: Text(quiz.name),
            subtitle: quiz.description != null ? Text(quiz.description!) : null,
              onTap: () {
              if (_selectionMode) {
                setState(() {
                  if (selected) _selected.remove(index); else _selected.add(index);
                });
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuizPage(quiz: quiz)));
            },
            onLongPress: () {
              setState(() {
                _selectionMode = true;
                _selected.add(index);
              });
            },
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'remove') {
                  if (quiz.sourcePath != null) {
                    try {
                      final f = File(quiz.sourcePath!);
                      if (await f.exists()) await f.delete();
                    } catch (_) {}
                  }
                  setState(() => _quizzes.removeAt(index));
                } else if (v == 'export') {
                  await _exportQuiz(quiz);
                } else if (v == 'edit') {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuizEditorPage(quiz: quiz)));
                } else if (v == 'publish') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publish not implemented')));
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'remove', child: Text('Remove')),
                PopupMenuItem(value: 'export', child: Text('Export')),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'publish', child: Text('Publish')),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateQuizDialog,
        tooltip: 'Create Quiz',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateQuizDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final authorCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Quiz'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: authorCtrl,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              final author = authorCtrl.text.trim();

              final toml = StringBuffer();
              toml.writeln('name = "${_escapeToml(name)}"');
              if (desc.isNotEmpty) toml.writeln('description = "${_escapeToml(desc)}"');
              if (author.isNotEmpty) toml.writeln('author = "${_escapeToml(author)}"');
              toml.writeln('random = true');

              try {
                final dir = await getApplicationDocumentsDirectory();
                final filename = '${name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.toml';
                final out = File('${dir.path}/$filename');
                await out.writeAsString(toml.toString());
                final quiz = Quiz.fromTomlString(toml.toString(), sourcePath: out.path);
                setState(() => _quizzes.add(quiz));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created quiz: ${quiz.name}')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  String _escapeToml(String s) => s.replaceAll('"', '\\"');
}
