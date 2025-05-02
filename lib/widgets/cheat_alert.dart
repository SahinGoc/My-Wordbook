import 'package:flutter/material.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:my_wordbook/utils/info_utils.dart';
import 'package:provider/provider.dart';

class CheatAlert extends StatefulWidget {
  const CheatAlert({super.key});

  @override
  State<CheatAlert> createState() => _CheatAlertState();
}

class _CheatAlertState extends State<CheatAlert> {
  TextEditingController cheatController = TextEditingController();

  @override
  dispose() {
    cheatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return viewAlert();
  }

  viewAlert() {
    return AlertDialog(
      title: Text(
        'Cheat Page',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(children: [
          cheatTextField(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          acceptButton()
        ]),
      ),
    );
  }

  cheatTextField() {
    return TextField(
      controller: cheatController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
      ),
    );
  }

  acceptButton() {
    return ElevatedButton(
        onPressed: () {
          cheatValidation();
        },
        child: Text('Onayla'));
  }

  cheatValidation() {
    if (cheatController.text.isNotEmpty) {
      if (cheatController.text == 'topNuman') {
        Provider.of<StoreOperations>(context, listen: false)
            .calculateMoney(2000);
        InfoUtils.showToast('Kod aktive edildi!');
        FocusScope.of(context).unfocus();
        cheatController.clear();
      } else {
        InfoUtils.showToast('Hatalı kod');
      }
    } else {
      InfoUtils.showToast('Lütfen bir kod girin');
    }
  }
}
