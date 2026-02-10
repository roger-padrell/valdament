import 'package:flutter/material.dart';

class QuestionLong extends StatefulWidget {
  final List<dynamic> options;
  final void Function(bool somethingSelected, bool isCorrect, {bool submitted_from_within}) onAnswerSelected;
  final bool checking;
  final int max;
  final bool ai;

  const QuestionLong({
    super.key, 
    required this.options, 
    required this.onAnswerSelected, 
    required this.checking,
    this.max = 40,
    this.ai = false,
  });

  @override
  State<QuestionLong> createState() => _QuestionLongState();
}

class _QuestionLongState extends State<QuestionLong> {
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
    return Column(children: [
      TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {
            text = value;
          });
          widget.onAnswerSelected(text.isNotEmpty, check());
        },
        readOnly: widget.checking,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Write your long answer here',
          filled: true,
          fillColor: widget.checking ? (check() ? Colors.green : Colors.red) : Colors.transparent,
        ),
        maxLength: widget.max,
        autocorrect: false,
        maxLines: null,
        keyboardType: TextInputType.multiline,
      ),
      Text(widget.checking && !check() ? "Correct answers include: ${widget.options.join(", ")}" : ""),
    ]);
  }
}
