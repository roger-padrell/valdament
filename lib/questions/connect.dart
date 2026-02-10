import 'package:flutter/material.dart';

class QuestionConnect extends StatefulWidget {
  final List<dynamic> pairs; // [["apple", "pomme"], ["orange", "naranja"]...]
  final void Function(bool somethingSelected, bool isCorrect) onAnswerSelected;
  final bool checking;
  final bool randomize_options;

  const QuestionConnect({
    super.key, 
    required this.pairs, 
    required this.onAnswerSelected, 
    required this.checking,
    required this.randomize_options,
  });

  @override
  State<QuestionConnect> createState() => _QuestionConnectState();
}

void swapSecond(List<(int, int)> list, int x, int y) {
  final temp = list[x].$2;

  list[x] = (list[x].$1, list[y].$2);
  list[y] = (list[y].$1, temp);
}

class _QuestionConnectState extends State<QuestionConnect> {
  var made_pairs = <(int, int)>[];
  var selected = -1;

  bool check() {
    for (var made_pair in made_pairs) {
      if(made_pair.$1 != made_pair.$2) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    
    final option_order = List.generate(widget.pairs.length, (i) => i);
    if(widget.randomize_options) {
      option_order.shuffle();
    }

    for (var i = 0; i < widget.pairs.length; i++) {
      made_pairs.add((i, option_order[i]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
       runSpacing: 8,
       alignment: WrapAlignment.center,
      children: [
      for (var i = 0; i < widget.pairs.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            ElevatedButton(onPressed: null, child: Text(widget.pairs[made_pairs[i].$1][0].toString())),
            ElevatedButton(
              onPressed: widget.checking ? (){} : () {
                setState(() {
                  if(selected == i) {
                    selected = -1;
                  }
                  else if(selected == -1) {
                    selected = i;
                  }
                  else{
                    swapSecond(made_pairs, selected, i);
                    selected = -1;
                  }
                });
                widget.onAnswerSelected(true, check());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.checking ? (made_pairs[i].$1 == made_pairs[i].$2 ? Colors.green : Colors.red) : (selected == i ? Colors.blue : null),
              ),
              child: Text(widget.pairs[made_pairs[i].$2][1].toString()),
            )
          ]),
        ),
    ]);
  }
}