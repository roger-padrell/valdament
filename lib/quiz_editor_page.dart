import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'quiz_model.dart';

class QuizEditorPage extends StatefulWidget {
  final Quiz quiz;
  const QuizEditorPage({super.key, required this.quiz});

  @override
  State<QuizEditorPage> createState() => _QuizEditorPageState();
}

class _QuizEditorPageState extends State<QuizEditorPage> {
  late TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quiz.rawToml);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final text = _controller.text;
    try {
      if (widget.quiz.sourcePath != null) {
        final file = File(widget.quiz.sourcePath!);
        await file.writeAsString(text);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to original file')));
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final out = File('${dir.path}/${widget.quiz.name.replaceAll(' ', '_')}.toml');
        await out.writeAsString(text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to ${out.path}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit: ${widget.quiz.name}')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
