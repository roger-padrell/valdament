import 'package:flutter/material.dart';

class QuestionShort extends StatefulWidget {
  final List<dynamic> options;
  final void Function(bool somethingSelected, bool isCorrect, {bool submitted_from_within}) onAnswerSelected;
  final bool checking;
  final int max;

  const QuestionShort({
    super.key, 
    required this.options, 
    required this.onAnswerSelected, 
    required this.checking,
    this.max = 40,
  });

  @override
  State<QuestionShort> createState() => _QuestionShortState();
}

class _QuestionShortState extends State<QuestionShort> {
  TextEditingController? _controller;
  String text = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: text);
  }

  bool check(){
    return widget.options.contains(text);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) {
        setState(() {
          text = value;
        });
        widget.onAnswerSelected(text.isNotEmpty, check());
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Write your short answer here',
      ),
      maxLength: widget.max,
      onSubmitted: (value) => {
        widget.onAnswerSelected(text.isNotEmpty, check(), submitted_from_within: true)
      },
    );
  }
}
