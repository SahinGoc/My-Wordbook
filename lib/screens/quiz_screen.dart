import 'package:my_wordbook/widgets/quiz_screen_widgets.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final int id;
  final int numbersOfQuestions;
  final int record;
  final int order;
  final int selectedDifficulty;
  const QuizScreen(
      {super.key,
      required this.id,
      required this.numbersOfQuestions,
      required this.record,
      required this.order,
      required this.selectedDifficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: QuizScreenWidgets(
      id: id,
      numbersOfQuestions: numbersOfQuestions,
      record: record,
      order: order,
      selectedDifficulty: selectedDifficulty,
    ));
  }
}
