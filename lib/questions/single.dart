import 'package:flutter/material.dart';

class QuestionSingle extends StatefulWidget {
  final List<dynamic> options;
  final List<dynamic> correct_options;
  final bool randomize_options;
  final void Function(bool somethingSelected, bool isCorrect) onAnswerSelected;
  final bool checking;

  const QuestionSingle({
    super.key, 
    required this.options, 
    required this.correct_options, 
    required this.onAnswerSelected, 
    required this.checking,
    required this.randomize_options,
  });

  @override
  State<QuestionSingle> createState() => _QuestionSingleState();
}

class _QuestionSingleState extends State<QuestionSingle> {
  late final List<int> option_order;
  var selected_option = -1;

  bool check() {
    return widget.correct_options.contains(selected_option);
  }

  @override
  void initState() {
    super.initState();
    
    option_order = List.generate(widget.options.length, (i) => i);
    if(widget.randomize_options) {
      option_order.shuffle();
    }
    option_order.shuffle();
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
                if(selected_option == option_order[i]) {
                  selected_option = -1;
                }
                else{
                  selected_option = option_order[i];
                }
              });
              widget.onAnswerSelected(selected_option != -1, check());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: 
                (widget.checking ? 
                  (widget.correct_options.contains(option_order[i]) ? 
                    Colors.green : 
                    (selected_option == option_order[i] ? 
                      Colors.red : 
                      null
                    )
                  ) : 
                  (selected_option == option_order[i] ? 
                    Colors.blue : 
                    null
                  ) 
                ) // backgroundColor
            ), // style
            child: Text(widget.options[option_order[i]].toString()),
          ),
        ),
    ]);
  }
}