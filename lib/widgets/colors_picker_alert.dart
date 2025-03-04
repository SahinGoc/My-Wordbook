import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:my_wordbook/providers/theme_operations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:my_wordbook/utils/info_utils.dart';
import 'package:provider/provider.dart';

import '../utils/color_utils.dart';

class ColorsPickerAlert extends StatefulWidget {
  final int subCategoryId;
  final int index;
  const ColorsPickerAlert(
      {super.key, required this.subCategoryId, required this.index});

  @override
  State<ColorsPickerAlert> createState() => _ColorsPickerAlertState();
}

class _ColorsPickerAlertState extends State<ColorsPickerAlert> {
  late Color currentColor;
  late Color tempColor;
  int selectedButton = 0;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    currentColor = Theme.of(context).primaryColor;
    tempColor = ColorUtils.getOptimalTextColor(context, currentColor);
  }

  @override
  Widget build(BuildContext context) {
    return alertDialog();
  }

  alertDialog() {
    return AlertDialog(
      title: Text(
        "Renk Seçin",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24.sp * Provider.of<ThemeOperations>(context)
              .getTextScaleFactor(context),
            color: ColorUtils.getOptimalTextColor(
          context,
          Theme.of(context).scaffoldBackgroundColor,
        )),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: SingleChildScrollView(
        child: Column(
          children: [
            pickerTitleRow(),
             SizedBox(
              height: 10.h,
            ),
            if (selectedButton == 0)
              simpleColorPicker()
            else
              detailedColorPicker()
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'İptal',
            style: TextStyle(
              fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor)),
          ),
          onPressed: () {
            AnalyticsService.logButtonClick('color_picker_cancel');
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            '1000 Puan',
            style: TextStyle(
              fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor)),
          ),
          onPressed: () async {
            final themeOperations =
                Provider.of<ThemeOperations>(context, listen: false);
            final storeOperations =
                Provider.of<StoreOperations>(context, listen: false);
            final control = await storeOperations.calculateMoney(-1000);
            if (control && mounted) {
              currentColor = tempColor;
              bool isDark = themeOperations.themeMode == ThemeMode.dark;
              storeOperations.setControl(widget.subCategoryId,
                  ColorUtils.adjustDoubleToIntColorValue(currentColor), widget.index, isDark);
              AnalyticsService.logButtonClick('color_picker_completed');
              Navigator.pop(context);
            } else {
              InfoUtils.showToast("Puanınız Yetersiz");
            }
          },
        ),
      ],
    );
  }

  pickerTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        simpleButton(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
          child: Container(
            width: 2.w,
            height: 60.h,
            color: ColorUtils.getOptimalTextColor(
              context,
              Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
        detailedButton()
      ],
    );
  }

  simpleButton() {
    return SizedBox(
      width: 120.w,
      height: 50.h,
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedButton = 0;
          });
        },
        style: TextButton.styleFrom(
            side: BorderSide(
              color: selectedButton == 0
                  ? ColorUtils.getOptimalTextColor(
                      context,
                      Theme.of(context).scaffoldBackgroundColor,
                    )
                  : Colors.transparent,
              width: selectedButton == 0 ? 2.0.r : 1.0.r,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r))),
        child: AutoSizeText(
          "BASİT",
          maxLines: 1,
          style: TextStyle(
              color: ColorUtils.getOptimalTextColor(
                context,
                Theme.of(context).scaffoldBackgroundColor,
              ),
              fontSize: 18.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  detailedButton() {
    return SizedBox(
      width: 120.w,
      height: 50.h,
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedButton = 1;
          });
        },
        style: TextButton.styleFrom(
            side: BorderSide(
              color: selectedButton == 1
                  ? ColorUtils.getOptimalTextColor(
                      context,
                      Theme.of(context).scaffoldBackgroundColor,
                    )
                  : Colors.transparent,
              width: selectedButton == 1 ? 2.0.r : 1.0.r,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "DETAYLI",
            maxLines: 1,
            style: TextStyle(
                color: ColorUtils.getOptimalTextColor(
                  context,
                  Theme.of(context).scaffoldBackgroundColor,
                ),
                fontSize: 18.sp * Provider.of<ThemeOperations>(context)
                    .getTextScaleFactor(context),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  simpleColorPicker() {
    return MaterialPicker(
      pickerColor: tempColor,
      onColorChanged: (color) {
        setState(() {
          tempColor = color;
        });
      },
    );
  }

  detailedColorPicker() {
    return ColorPicker(
      pickerColor: tempColor,
      onColorChanged: (color) {
        setState(() {
          tempColor = color;
        });
      },
      enableAlpha: false,
      pickerAreaHeightPercent: 0.9,
    );
  }
}
