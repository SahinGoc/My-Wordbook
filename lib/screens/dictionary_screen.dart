import 'package:my_wordbook/widgets/dictionary_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../widgets/quiz_menu_alert.dart';

class DictionaryScreen extends StatelessWidget {
  final int id;
  const DictionaryScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: DictionaryScreenWidgets(id: id),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return QuizMenuAlert(id: id);
              },
            );
          },
          backgroundColor:
              Theme.of(context).floatingActionButtonTheme.backgroundColor,
          child: PhosphorIcon(PhosphorIconsBold.bookOpenText,
              size: 28,
              color:
                  Theme.of(context).floatingActionButtonTheme.foregroundColor),
        ),
      ),
    );
  }
}
