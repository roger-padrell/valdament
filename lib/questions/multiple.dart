import 'package:flutter/material.dart';

class QuestionMultiple extends StatefulWidget {
  final List<dynamic> options;
  final List<dynamic> correct_options;
  final void Function(bool somethingSelected, bool isCorrect) onAnswerSelected;
  final bool checking;
  final bool randomize_options;

  const QuestionMultiple({
    super.key, 
    required this.options, 
    required this.correct_options, 
    required this.onAnswerSelected, 
    required this.checking,
    required this.randomize_options,
  });

  @override
  State<QuestionMultiple> createState() => _QuestionMultipleState();
}

class _QuestionMultipleState extends State<QuestionMultiple> {
  late final List<int> option_order;
  var selected_options = <int>[];

  bool check() {
    return selected_options.every((option) => widget.correct_options.contains(option)) && 
      widget.correct_options.every((option) => selected_options.contains(option));
  }

  @override
  void initState() {
    super.initState();
    
    option_order = List.generate(widget.options.length, (i) => i);
    if(widget.randomize_options) {
      option_order.shuffle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
       runSpacing: 8,
       alignment: WrapAlignment.center,
      children: [
      for (var i = 0; i < widget.options.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: widget.checking ? (){} : () {
              setState(() {
                if(selected_options.contains(option_order[i])) {
                  selected_options.remove(option_order[i]);
                }
                else{
                  selected_options.add(option_order[i]);
                }
              });
              widget.onAnswerSelected(selected_options.isNotEmpty, check());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (widget.checking ? (
                widget.correct_options.contains(option_order[i]) ? 
                  Colors.green : 
                  (selected_options.contains(option_order[i]) ? 
                    Colors.red : 
                    null
                  )
                ) : 
                (selected_options.contains(option_order[i]) ? 
                  Colors.blue : 
                  null
                )
              )
            ),
            child: Text(widget.options[option_order[i]].toString()),
          ),
        ),
    ]);
  }
}