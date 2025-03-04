import 'package:my_wordbook/widgets/online_translator_widgets.dart';
import 'package:flutter/material.dart';

class OnlineTranslatorScreen extends StatelessWidget {
  const OnlineTranslatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () {
      FocusScope.of(context).unfocus();
    }, child: const Scaffold(body: OnlineTranslatorWidgets(),));
  }
}

