import 'package:my_wordbook/widgets/store_screen_widgets.dart';
import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(onPopInvokedWithResult: (didPop, result) {
      if (didPop) {
        Future.microtask(() {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false);
          }
        });
      }
    },
    child: const Scaffold(body: StoreScreenWidgets()));
  }
}
