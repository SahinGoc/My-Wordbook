import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:flutter/material.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:my_wordbook/utils/info_utils.dart';
import 'package:provider/provider.dart';

import '../providers/theme_operations.dart';
import '../utils/color_utils.dart';

class SetTitleAlert extends StatefulWidget {
  const SetTitleAlert({super.key});

  @override
  State<SetTitleAlert> createState() => _SetTitleAlertState();
}

class _SetTitleAlertState extends State<SetTitleAlert>
    with SingleTickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.red, end: Colors.green), weight: 1),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.green, end: Colors.blue),
            weight: 1),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.blue, end: Colors.yellow),
            weight: 1),
      ],
    ).animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return alertDialog();
  }

  alertDialog() {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        '1000 puana Başlık?'
            .toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22.sp * Provider.of<ThemeOperations>(context)
              .getTextScaleFactor(context),
            fontWeight: FontWeight.bold,
            color: _colorAnimation.value ??
                ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor)),
      ),
      actions: [
        TextButton(
            onPressed: () async {
              AnalyticsService.logButtonClick('title_change');
              Provider.of<StoreOperations>(context, listen: false)
                  .calculateMoney(1000);
              if (controller.text.isNotEmpty) {
                if (await (Provider.of<StoreOperations>(context, listen: false)
                        .calculateMoney(-1000)) &&
                    mounted) {
                  Provider.of<StoreOperations>(context, listen: false)
                      .setTitle(controller.text);
                  Navigator.pop(context);
                } else {
                  InfoUtils.showToast('Puanınız yetersiz!');
                }
              } else {
                InfoUtils.showToast('Başlık alanı boş olamaz!');
              }
            },
            child: Text(
              'YAP HADİ!',
              style: TextStyle(
                  color: _colorAnimation.value ??
                      ColorUtils.getOptimalTextColor(
                          context, Theme.of(context).scaffoldBackgroundColor),
                  fontSize: 24.sp * Provider.of<ThemeOperations>(context)
                      .getTextScaleFactor(context),
                  fontWeight: FontWeight.bold),
            ))
      ],
      actionsAlignment: MainAxisAlignment.center,
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextField(
              controller: controller,
              style: TextStyle(color: _colorAnimation.value ??
                  ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
              cursorColor: _colorAnimation.value ??
                  ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: _colorAnimation.value!, width: 4.0.r),
                    borderRadius: BorderRadius.circular(20.0.r)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        _colorAnimation.value ?? Colors.blue, // Varsayılan renk
                    width: 4.0.r,
                  ),
                  borderRadius: BorderRadius.circular(20.0.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        _colorAnimation.value ?? Colors.red, // Varsayılan renk
                    width: 4.0.r,
                  ),
                  borderRadius: BorderRadius.circular(20.0.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
