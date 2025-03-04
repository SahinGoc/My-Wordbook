import 'package:my_wordbook/widgets/add_dictionary_alert.dart';
import 'package:my_wordbook/widgets/main_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: MainScreenWidgets(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddDictionaryAlert(),
            );
          },
          child: const PhosphorIcon(PhosphorIconsRegular.circlesThreePlus, size: 32),
        ),
      ),
    );
  }
}
