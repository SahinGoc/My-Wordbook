import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/providers/dictionary_operations.dart';
import 'package:flutter/material.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/theme_operations.dart';
import '../services/ad_service.dart';
import '../utils/color_utils.dart';
import '../utils/info_utils.dart';

class QuizMenuAlert extends StatefulWidget {
  final int id;
  const QuizMenuAlert({super.key, required this.id});

  @override
  State<QuizMenuAlert> createState() => _QuizMenuAlertState();
}

class _QuizMenuAlertState extends State<QuizMenuAlert> {
  late int id;
  int record = 0;
  int totalNumber = 0;
  late int selectedNumber;
  late List<int> numbersList = [];
  int selectedOrder = 1;
  List<String> orderList = ['K / A','Rastgele', 'A / K'];
  int selectedDifficult = 0;
  List<String> difficultList = ['Kolay', 'Zor'];
  int selectedNumberIndex = 0;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    _fetchTotalNumber();
    _fetchRecord();
  }

  void _fetchTotalNumber() async {
    try {
      int number =
          await Provider.of<DictionaryOperations>(context, listen: false)
              .getTotalNumber(id);
      setState(() {
        totalNumber = number;
        numbersList = getSelectableNumbers(totalNumber);
        selectedNumber = numbersList.first;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _fetchRecord() async {
    try {
      int rec = await Provider.of<DictionaryOperations>(context, listen: false)
          .getRecord(id);
      setState(() {
        record = rec;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  List<int> getSelectableNumbers(int totalWords) {
    List<int> numbers = [];
    if (totalWords <= 10) {
      for (int i = 1; i <= totalWords; i++) {
        numbers.add(i);
      }
    } else if (totalWords <= 25) {
      for (int i = 5; i <= totalWords; i += 5) {
        numbers.add(i);
      }
    } else if (totalWords <= 200) {
      for (int i = 5; i <= totalWords; i += (i < 25 ? 5 : 25)) {
        numbers.add(i);
      }
    } else {
      for (int i = 5;
          i <= totalWords;
          i += (i < 25
              ? 5
              : i < 200
                  ? 25
                  : 50)) {
        numbers.add(i);
      }
    }
    if (!numbers.contains(totalWords)) {
      numbers.add(totalWords);
    }
    return numbers;
  }

  @override
  Widget build(BuildContext context) {
    return alertDialog();
  }

  alertDialog() {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: titleColumn(),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            //Rekor ve kelime sayısı
            recordAndWordsNumber(),
             SizedBox(
              height: 20.h,
            ),
            //Soru sayısı
            numberOfQuestions(),
             SizedBox(
              height: 20.h,
            ),
            //Düzen Seçimi
            selectOrder(),
             SizedBox(
              height: 20.h,
            ),
            selectDifficult(),
             SizedBox(
              height: 20.0.h,
            ),
            // Quiz'i başlatma butonu
            startButton(),
          ],
        ),
      ),
    );
  }

  titleColumn() {
    return Column(
      children: [
        Text(
          'Soru Sayını Seç',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 24.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
              fontWeight: FontWeight.bold,
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
        SizedBox(
          height: 5.h,
        ),
        Text(
          'Kendini Dene!',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ],
    );
  }

  // Rekor ve kelime sayısı
  recordAndWordsNumber() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Kelime: $totalNumber',
              style: TextStyle(
                  fontSize: 12.sp * Provider.of<ThemeOperations>(context)
                      .getTextScaleFactor(context),
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor))),
        ),
         SizedBox(
          width: 15.w,
        ),
        Text('Rekor: $record',
            style: TextStyle(
                fontSize: 12.sp * Provider.of<ThemeOperations>(context)
                    .getTextScaleFactor(context),
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor))),
      ],
    );
  }

  //Sorulacak soru sayısı
  numberOfQuestions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            PhosphorIcon(PhosphorIconsBold.caretLeft,
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor)),
             SizedBox(width: 4.w),
            numberListView(),
            const SizedBox(width: 4),
            PhosphorIcon(PhosphorIconsBold.caretRight,
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor)),
          ],
        ),
      ],
    );
  }

  numberListView() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
              width: 2.0.r),
          borderRadius:  BorderRadius.all(Radius.circular(20.0.r))),
      constraints:  BoxConstraints(minWidth: 80.w, maxWidth: 200.w),
      height: 80.h,
      width: numbersList.length * 75.h > 180.h
          ? 200.h
          : numbersList.length * 75.h.toDouble(),
      padding:  EdgeInsets.only(
          left: 0.6.w, right: 0.6.w, top: 4.h, bottom: 4.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: numbersList.length,
        shrinkWrap: true,
        itemExtent: 75,
        itemBuilder: (context, index) {
          return numberContainer(index);
        },
      ),
    );
  }

  numberContainer(int index) {
    return GestureDetector(
      child: Center(
        child: Padding(
          padding:  EdgeInsets.all(4.0.r),
          child: Container(
            width: 100.w,
            decoration: BoxDecoration(
                color: selectedNumberIndex == index
                    ? ColorUtils.getOptimalTextColor(context,
                    Theme.of(context).scaffoldBackgroundColor)
                    : ColorUtils.getOptimalTextColor(
                    context,
                    Theme.of(context)
                        .scaffoldBackgroundColor)
                    .withAlpha(25),
                border: Border.all(
                    color: ColorUtils.getOptimalTextColor(
                        context,
                        Theme.of(context)
                            .scaffoldBackgroundColor)),
                borderRadius:  BorderRadius.all(
                    Radius.circular(20.0.r))),
            alignment: Alignment.center,
            child: numberText(index),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          selectedNumber = numbersList[index];
          selectedNumberIndex = index;
        });
      },
    );
  }

  numberText(int index) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        numbersList[index].toString(),
        style: TextStyle(
            color: selectedNumberIndex == index
                ? Theme.of(context).scaffoldBackgroundColor
                : ColorUtils.getOptimalTextColor(
                context,
                Theme.of(context)
                    .scaffoldBackgroundColor),
            fontWeight: FontWeight.bold,
        fontSize: 14.sp * Provider.of<ThemeOperations>(context)
            .getTextScaleFactor(context)),
      ),
    );
  }

  selectOrder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        orderList.length,
            (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedOrder = index;
              });
            },
            child: orderContainer(index),
          );
        },
      ),
    );
  }

  orderContainer(int index) {
    return Padding(
      padding:  EdgeInsets.all(4.0.r),
      child: Container(
        width: 82.w,
        height: 65.h,
        decoration: BoxDecoration(
          color: selectedOrder == index
              ? ColorUtils.getOptimalTextColor(context,
              Theme.of(context).scaffoldBackgroundColor)
              : ColorUtils.getOptimalTextColor(context,
              Theme.of(context).scaffoldBackgroundColor)
              .withAlpha(25),
          border: Border.all(
              color: ColorUtils.getOptimalTextColor(context,
                  Theme.of(context).scaffoldBackgroundColor),
              width: 2.r),
          borderRadius:
          BorderRadius.all(Radius.circular(15.0.r)),
        ),
        child: orderText(index),
      ),
    );
  }

  orderText(int index) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 2.0.h, horizontal: 6.0.w),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            orderList[index],
            maxLines: 2,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: selectedOrder == index
                  ? Theme.of(context).scaffoldBackgroundColor
                  : ColorUtils.getOptimalTextColor(context,
                  Theme.of(context).scaffoldBackgroundColor),
              fontWeight: FontWeight.bold,
              fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context)
            ),
          ),
        ),

      ),
    );
  }

  selectDifficult() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        difficultList.length,
        (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDifficult = index;
              });
            },
            child: Padding(
              padding:  EdgeInsets.all(5.0.r),
              child: Stack(
                children: [
                  difficultContainer(index),
                  difficultQuestionMark(index),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  difficultContainer(int index) {
    return Container(
      width: 88.w,
      height: 68.h,
      decoration: BoxDecoration(
        color: selectedDifficult == index
            ? ColorUtils.getOptimalTextColor(context,
            Theme.of(context).scaffoldBackgroundColor)
            : ColorUtils.getOptimalTextColor(context,
            Theme.of(context).scaffoldBackgroundColor)
            .withAlpha(25),
        border: Border.all(
            color: ColorUtils.getOptimalTextColor(context,
                Theme.of(context).scaffoldBackgroundColor),
            width: 2.r),
        borderRadius:
        BorderRadius.all(Radius.circular(15.0.r)),
      ),
      child: difficultText(index),
    );
  }

  difficultText(int index) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          difficultList[index],
          style: TextStyle(
            color: selectedDifficult == index
                ? Theme.of(context).scaffoldBackgroundColor
                : ColorUtils.getOptimalTextColor(context,
                Theme.of(context).scaffoldBackgroundColor),
            fontWeight: FontWeight.bold,
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context)
          ),
        ),
      ),
    );
  }

  difficultQuestionMark(int index) {
    return Positioned(
      right: -10.0.w,
      top: -8.0.h,
      child: IconButton(
        onPressed: () {
          if (selectedDifficult == index) {
            InfoUtils.showToast(
                'Doğru cevabı bulana kadar deneyebilirsiniz.');
            AnalyticsService.logButtonClick('quiz_menu_easy_description');
          } else {
            InfoUtils.showToast(
                'Kelimeyi onayladığınız an diğer soruya geçer.');
            AnalyticsService.logButtonClick('quiz_menu_hard_description');
          }
        },
        icon: const PhosphorIcon(PhosphorIconsBold.questionMark),
        iconSize: 16.0.sp,
        padding: EdgeInsets.zero,
        color: selectedDifficult == index
            ? Theme.of(context).scaffoldBackgroundColor
            : ColorUtils.getOptimalTextColor(context,
            Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }

  startButton() {
    return GestureDetector(
      onTap: () async {
        if (totalNumber == 0) {
          InfoUtils.showToast("Lütfen kelime ekleyiniz!");
        } else {
          if (!mounted) return;

          if (mounted) Navigator.pop(context);

          AnalyticsService.logButtonClick('start_quiz');
          AnalyticsService.logScreenView('quiz');
          Provider.of<AdService>(context, listen: false).showInterstitialAd();
          Navigator.pushNamed(
            context,
            '/quiz',
            arguments: {
              'id': widget.id,
              'numberOfQuestions': selectedNumber,
              'record': record,
              'order': selectedOrder + 1,
              'selectedDifficulty': selectedDifficult
            },
          );
        }
      },
      child: PhosphorIcon(
        PhosphorIconsFill.play,
        color: ColorUtils.getOptimalTextColor(
            context, Theme.of(context).scaffoldBackgroundColor),
        size: 64.sp,
      ),
    );
  }
}
