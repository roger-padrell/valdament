import 'package:flutter/material.dart';
import 'quiz_model.dart';
import 'package:toml/toml.dart';

import 'questions/single.dart';
import 'questions/multiple.dart';
import 'questions/connect.dart';
import 'questions/short.dart';
import 'questions/long.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;

  const QuizPage({super.key, required this.quiz});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class QuestionWidget extends StatelessWidget{
  final Map<String, dynamic> parsed_quiz;
  final int questionNumber;
  final int total_questions;
  final bool checking;
  final void Function(bool somethingSelected, bool isCorrect, {bool submitted_from_within}) onAnswerSelected;
  QuestionWidget({
    required this.parsed_quiz,
    required this.questionNumber,
    required this.total_questions,
    required this.onAnswerSelected,
    required this.checking,
  });

  @override
  Widget build(BuildContext context) {
    if(questionNumber >= total_questions) {
      return const Text("Quiz completed!");
    }
    
    if(parsed_quiz['question'][questionNumber]['type'] == 'single') {
      return QuestionSingle(options: parsed_quiz['question'][questionNumber]['options'], correct_options: parsed_quiz['question'][questionNumber]['correct'], onAnswerSelected: onAnswerSelected, key: ValueKey(questionNumber), checking: checking, randomize_options: parsed_quiz['question'][questionNumber]['random'] ?? false);
    }
    else if(parsed_quiz['question'][questionNumber]['type'] == 'multiple') {
      return QuestionMultiple(options: parsed_quiz['question'][questionNumber]['options'], correct_options: parsed_quiz['question'][questionNumber]['correct'], onAnswerSelected: onAnswerSelected, key: ValueKey(questionNumber), checking: checking, randomize_options: parsed_quiz['question'][questionNumber]['random'] ?? false);
    }
    else if(parsed_quiz['question'][questionNumber]['type'] == 'long') {
      return QuestionLong(options: parsed_quiz['question'][questionNumber]['options'], onAnswerSelected: onAnswerSelected, key: ValueKey(questionNumber), checking: checking, max: parsed_quiz['question'][questionNumber]['max'] ?? 40, ai: parsed_quiz['question'][questionNumber]['ai'] ?? false);
    }
    else if(parsed_quiz['question'][questionNumber]['type'] == 'connect') {
      return QuestionConnect(pairs: parsed_quiz['question'][questionNumber]['pairs'], onAnswerSelected: onAnswerSelected, key: ValueKey(questionNumber), checking: checking, randomize_options: parsed_quiz['question'][questionNumber]['random'] ?? false);
    }
    else if(parsed_quiz['question'][questionNumber]['type'] == 'short') {
      return QuestionShort(options: parsed_quiz['question'][questionNumber]['options'], onAnswerSelected: onAnswerSelected, key: ValueKey(questionNumber), checking: checking, max: parsed_quiz['question'][questionNumber]['max'] ?? 10);
    }
    else {
      return const Text("Unknown question type");
    }
  }
}

class _QuizPageState extends State<QuizPage> {
  var question_count = 0;
  var questionNumber = 0;
  var answer_selected = false;
  var is_correct = false;
  var checking = false;
  List<int>? answers; // 0 = unanswered, 1 = correct, -1 = incorrect
  List<int>? question_order;
  late Map<String, dynamic> parsed_quiz;
  late int total_questions;

  @override
  void initState() {
    super.initState();

    parsed_quiz = (TomlDocument.parse(widget.quiz.rawToml)).toMap();
    total_questions = parsed_quiz['question'].length;
    question_order = List.generate(total_questions, (i) => i);
    if(parsed_quiz['random'] == true) {
      question_order?.shuffle();
    }
  
    answers = List.filled(total_questions, 0);
  }

  void submitButton() {
    if(answer_selected) {
      // check
      setState(() {
        if(checking){
          question_count++;
          answer_selected = false;
          is_correct = false;
          checking = false;
        }
        else{
          checking = true;
          answers?[questionNumber] = is_correct ? 1 : -1;
        }
      });
    } else {
      // skip
      setState(() {
        question_count++;
        answer_selected = false;
        is_correct = false;
        checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (question_order == null || answers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if(question_count >= total_questions) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.name)),
        body: Center(child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Quiz completed!", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),),
            SizedBox(height: 20.0,),
            Text("Your score: " + answers!.where((a) => a == 1).length.toString() + " / " + total_questions.toString(), style: TextStyle(fontSize: 18.0),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for(int n = 0; n < total_questions; n++)
                  Container(
                    width: 7,
                    height: 7,
                    margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: answers?[n] == 0 ? Colors.grey : (answers?[n] == 1 ? Colors.green : Colors.red),
                    ),
                  )
                ],
            ),
          ],
        )),
      );
    }
    setState(() => questionNumber = question_order![question_count]);

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question " + (question_count + 1).toString() +" of $total_questions"),
                  Row(children: [
                    for(int n = 0; n < total_questions; n++)
                      Container(
                        width: 7,
                        height: 7,
                        margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: n == questionNumber ? Colors.blue : (answers?[n] == 0 ? Colors.grey : (answers?[n] == 1 ? Colors.green : Colors.red)),
                        ),
                      )
                  ],),
                  Text(parsed_quiz['question'][questionNumber]['query'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
                  SizedBox(height: 10.0,),
                  SizedBox(
                    child: QuestionWidget(parsed_quiz: parsed_quiz, questionNumber: questionNumber, total_questions: total_questions, onAnswerSelected: (bool something_selected, bool correct, {bool submitted_from_within=false}) => setState(() {answer_selected = something_selected; is_correct = correct; if(submitted_from_within) {submitButton();}}), checking: checking,)
                  ),
                ],
              ),
            ),
            Align(
              key: const ValueKey('check_button'),
              alignment: Alignment.bottomCenter,
              child:  FractionallySizedBox(
                widthFactor: 0.9,
                child: ElevatedButton(
                  onPressed: () => {submitButton()},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: checking ? (is_correct ? Colors.green : Colors.red) : (answer_selected ? Colors.blue : Colors.grey),
                  ),
                  child: Text(answer_selected ? (checking ? "Next Question" : "Check Answer") : "Skip", style: TextStyle(color: Colors.white)),
                )
              ),
            ),
          ]
        ),
      ),
    );
  }
}
